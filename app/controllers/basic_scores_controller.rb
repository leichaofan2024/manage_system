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
        	@quarter = quarter[0]
        else 
            @quarter = quarter_hash[Time.now.month]
        end 
	  end 
	  if current_user.has_role? :workshopadmin
	  	@basic_scores = BasicScore.where(:workshop => Workshop.find_by(:id =>current_user.workshop).name,:year => @year,:quarter => @quarter)
	  elsif (current_user.has_role? :staradmin)  || (current_user.has_role? :superadmin) || (current_user.has_role? :leaderadmin) || (current_user.has_role? :depudy_leaderadmin)
        @basic_scores = BasicScore.where(:year => @year,:quarter => @quarter)
      end 

	  respond_to do |format| 
	  	format.html
	  	format.xls

	  end 
	end 

	def import_basic_score 
		if params[:workshop].present？ and params[:year].present? and params[:quarter].present? 
			if params[:file].present? 
			  BasicScore.import_table(params[:file],params[:workshop],params[:year],params[:quarter])
			  flash[:notice] = "#{params[:workshop]}#{params[:year]}年第#{params[:quarter]}季度考勤汇总表，上传成功！"
		    else 
		      flash[:warning] = "您还没有选择文件哦！"
            end 
		else 
          flash[:alert] = "请正确选择所属车间、年份、季度信息！"
		end 
		redirect_to fallback_location: basic_scores_path
	end 

	def delete_basic_score
		basic_score = BasicScore.find_by(year: params[:year],quarter: params[:quarter],workshop: params[:workshop])
		if !basic_score.present?
			flash[:warning] = "#{params[:workshop]}#{params[:year]}年第#{params[:quarter]}季度考勤汇总表，还未上传，无需删除！"
		elsif (basic_score.confirm_status == 0)
			basic_scores = BasicScore.where(year: params[:year],quarter: params[:quarter],workshop: params[:workshop])
			star_infoes = StarInfo.where(year: params[:year],quarter: params[:quarter],workshop: params[:workshop])
			basic_scores.delete_all
			star_infoes.delete_all
			flash[:notice] = "#{params[:workshop]}#{params[:year]}年第#{params[:quarter]}季度考勤汇总表，删除成功！"
		else 
			flash[:alert] = "#{params[:workshop]}#{params[:year]}年第#{params[:quarter]}季度考勤汇总表已上报至劳资，不能删除！"
		end 
		redirect_to fallback_location: basic_scores_path
	end 
end
