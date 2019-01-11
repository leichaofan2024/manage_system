class BasicScoresController < ApplicationController
	layout 'home'

	def index
	  @years = BasicScore.pluck(:year).uniq.sort{|a,b| b<=>a}
	  @quarters = BasicScore.pluck(:quarter).uniq.sort{|a,b| b<=> a}
	  quarter_hash = {1=>1,2=>1,3=>1,4=>2,5=>2,6=>2,7=>3,8=>3,9=>3,10=>4,11=>4,12=>4}
	  if params[:year].present? 
	  	@year = params[:year].to_i 
	  else 
	  	@year = Time.now.year 
	  end 
	  if params[:quarter].present? 
	    @quarter = params[:quarter].to_i 
	  else 
        quarters = BasicScore.where(:year => Time.now.year).pluck(:quarter).uniq.sort{|a,b| b<=> a}
        if quarters.present? 
        	@quarter = quarters[0]
        else 
            @quarter = quarter_hash[Time.now.month]
        end 
	  end      
	  if current_user.has_role? :workshopadmin
	  	@basic_scores = BasicScore.where(:workshop => Workshop.find_by(:id =>current_user.workshop_id).name,:year => @year,:quarter => @quarter)
	  	@groups = @basic_scores.pluck(:group).uniq
	  	@dutys = @basic_scores.pluck(:duty).uniq
	  elsif (current_user.has_role? :staradmin)  || (current_user.has_role? :superadmin) || (current_user.has_role? :leaderadmin) || (current_user.has_role? :depudy_leaderadmin)
        @basic_scores = BasicScore.where(:year => @year,:quarter => @quarter)
        @workshops = @basic_scores.pluck(:workshop).uniq
        groups_array = [[]]
        @workshops.each do |workshop|
        	groups = @basic_scores.where(:workshop => workshop).pluck(:group).uniq
        	groups_array << groups 
        end 
        @dutys = @basic_scores.pluck(:duty).uniq
      end 
      gon.groups = groups_array
      if params[:workshop].present?
      	@basic_scores = @basic_scores.where(:workshop => params[:workshop])
      end 
      if params[:group].present?
      	@basic_scores = @basic_scores.where(:group => params[:group])
      end
      if params[:duty].present?
      	@basic_scores = @basic_scores.where(:duty => params[:duty])
      end
      if params[:star].present?
      	if @basic_scores.present? 
	      basic_score_ids = StarInfo.where(:basic_score_id => @basic_scores.ids).where(:star => params[:star]).pluck(:basic_score_id).uniq
	      @basic_scores = @basic_scores.where(:id => basic_score_ids)
	    end 
      end
      @basic_scores_export = @basic_scores
      @basic_scores = @basic_scores.page(params[:page]).per(20)
      
	  respond_to do |format| 
	  	format.html
	  	format.xls { headers["Content-Disposition"] = 'attachment; filename="星级岗成绩汇总表.xls"'}

	  end 
	end 

	def import_basic_score 
		if params[:workshop].present? and params[:year].present? and params[:quarter].present?
			if params[:file].present? 
			  message = BasicScore.import_table(params[:file],params[:workshop],params[:year],params[:quarter])
			  if message[:head].present? 
			  	flash[:alert] = message[:head]
			  elsif message[:year_quarter].present? 
			  	flash[:alert] = message[:year_quarter]
			  else
				flash[:notice] = "#{params[:workshop]}#{params[:year]}年第#{params[:quarter]}季度考勤汇总表，上传成功！"
			  end 
		    else 
		      flash[:warning] = "您还没有选择文件哦！"
            end 
		else 
          flash[:alert] = "请正确选择所属车间、年份、季度信息！"
		end 
		redirect_back fallback_location: basic_scores_path
	end 
    
    def import_model
      @quarter_hash = {1=>1,2=>1,3=>1,4=>2,5=>2,6=>2,7=>3,8=>3,9=>3,10=>4,11=>4,12=>4}
      @workshops = Workshop.current
      @years = ((Time.now.year-5)..(Time.now.year)).sort{|a,b| b<=>a}
      @quarters = [4,3,2,1]
    end 

	def delete_basic_score
		basic_score = BasicScore.find_by(year: params[:year],quarter: params[:quarter],workshop: params[:workshop])
		if !basic_score.present?
			flash[:warning] = "#{params[:workshop]}#{params[:year]}年第#{params[:quarter]}季度考勤汇总表，还未上传，无需删除！"
		elsif (basic_score.confirm_status == false)
			basic_scores = BasicScore.where(year: params[:year],quarter: params[:quarter],workshop: params[:workshop])
			star_infoes = StarInfo.where(year: params[:year],quarter: params[:quarter],workshop: params[:workshop])
			basic_scores.delete_all
			star_infoes.delete_all
			flash[:notice] = "#{params[:workshop]}#{params[:year]}年第#{params[:quarter]}季度考勤汇总表，删除成功！"
		elsif (basic_score.confirm_status == true)
			flash[:alert] = "#{params[:workshop]}#{params[:year]}年第#{params[:quarter]}季度考勤汇总表已上报至劳资，不能删除！"
		end 
		redirect_back fallback_location: basic_scores_path
	end 

	#上报成绩汇总表
	def confirm_basic_score
		basic_score = BasicScore.find_by(year: params[:year],quarter: params[:quarter],workshop: params[:workshop],:confirm_status => 1)
		if basic_score.present? 
			flash[:warning] = "《#{params[:workshop]}》#{params[:year]}年#{params[:quarter]}季度星级岗成绩汇总表，已上报，无需重复上报！"
		else 
			basic_scores = BasicScore.where(year: params[:year],quarter: params[:quarter],workshop: params[:workshop])
			basic_scores.update(:confirm_status => 1)
			flash[:notice] = "《#{params[:workshop]}》#{params[:year]}年#{params[:quarter]}季度星级岗成绩汇总表，上报完成！"
		end 
		redirect_back :fallback_location => basic_scores_path
	end 

	def descend_record
		year = params[:year]
		quarter = params[:quarter]
		sal_number = params[:sal_number]
		if (year.present?) && (quarter.present?)
			@records = DescendRecord.where(year: year, quarter: quarter)
		elsif (sal_number.present?) && (year.present?)
			@records = DescendRecord.where(sal_number: sal_number, year: year)
		else
			@records = DescendRecord.all
		end

		@export_records = DescendRecord.where(id: params[:export_records])
		respond_to do |format|
      format.html
      format.js
      format.xls { headers["Content-Disposition"] = 'attachment; filename="班组长降星记录表.xls"'}
    end
	end

	def filter_descend_record
		redirect_to :action => "descend_record", year: params[:year], quarter: params[:quarter]
	end
end
