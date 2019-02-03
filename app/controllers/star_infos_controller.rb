class StarInfosController < ApplicationController
	before_action :validate_search_key, only: [:search]
	layout 'home'

	def all_star_info
		# 配置车间班组筛选框数据
		workshop = StarInfo.pluck("workshop").uniq
		@group = [["--选择班组--"]]
	    workshop.each do |name|
	      @group << StarInfo.where(workshop: name).pluck(:group).uniq
	    end
	    gon.group_name = @group
		@workshop_names = StarInfo.pluck("workshop").uniq

		@year = params[:year]
		@quarter = params[:quarter]
		quarter_month = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]]
		quarter_month.each do |i|
			if i.include?(Time.now.month)
				@current_quarter = (quarter_month.index(i) + 1)
			end
		end
		if params[:type] == "1"
			@type = 1
		else
			@type = [0, 1]
		end
		if params[:year].present?
			@year = params[:year]
			@quarter = params[:quarter]
		else
			@year = Time.now.year
			@quarter = @current_quarter
		end
		if params[:basic_score_ids].present?
			@scores = BasicScore.where(id: params[:basic_score_ids], confirm_status: @type, year: @year, quarter: @quarter)
		else
			if params[:condition].present?
				@scores = []
				flash[:alert] = "未找到符合条件的人员"
			else
				@scores = BasicScore.where(confirm_status: @type, year: @year, quarter: @quarter)
			end
		end
		@export_scores = BasicScore.where(id: params[:export_scores])
		respond_to do |format|
      format.html
      format.js
      format.xls { headers["Content-Disposition"] = 'attachment; filename="全部星级岗位表.xls"'}
    end
	end

	def show_star_modal
		@star_info = params[:star_info]
		respond_to do |format|
			format.js
		end
	end

	def update_star
		@scores = BasicScore.all
		star = StarInfo.find(params[:star_info])
		basic_score = BasicScore.find(star.basic_score_id)
		updated_star = (star.star).to_i + (params[:update_type] + params[:star_count]).to_i
		if basic_score.confirm_status == true
			if (updated_star > 5) || (updated_star < 1)
				flash[:alert] = "升/降星后该人员的星级高于五星或低于一星，请检查"
			else
				star.update(star: updated_star)
				flash[:notice] = "更新完成"	
			end	
		else
			flash[:alert] = "您还未完成本季度的评定，请完成后再处理申请"
		end
		redirect_to all_star_info_star_infos_path
	end

	def search
		if @query_string.present?
			@scores = search_params
		end
	end

	def filter
		if params[:workshop] == "--选择车间--"
			params[:workshop] = nil
		end
		if params[:group] == "--选择班组--"
			params[:group] = nil
		end
		
		# 配置车间班组筛选框数据
		workshop = StarInfo.pluck("workshop").uniq
		@group = [["--选择班组--"]]
	    workshop.each do |name|
	      @group << StarInfo.where(workshop: name).pluck(:group).uniq
	    end
	    gon.group_name = @group
		@workshop_names = StarInfo.pluck("workshop").uniq
		@year = params[:year]
		@quarter = params[:quarter]
		@params_workshop = params[:workshop]
		@params_group = params[:group]
		quarter_month = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]]
		quarter_month.each do |i|
			if i.include?(Time.now.month)
				@current_quarter = (quarter_month.index(i) + 1)
			end
		end
		if params[:year].present?
			@year = params[:year]
			@quarter = params[:quarter]
		else
			@year = Time.now.year
			@quarter = @current_quarter
		end
		condition = ".where(year: #{@year}, quarter: #{@quarter}"
	    if params[:workshop].present?
	      condition += ", workshop: '#{params[:workshop]}'"
	    end
	    if params[:group].present?
	      condition += ", group: '#{params[:group]}'"
	    end
	    if params[:duty].present?
	      condition += ", duty: '#{params[:duty]}'"
	    end
	    if params[:star].present?
	      condition += ", star: '#{params[:star]}'"
	    end
	    condition += ")"
	    basic_score_ids = eval("StarInfo#{condition}").pluck(:basic_score_id)
		redirect_to :action => "all_star_info", basic_score_ids: basic_score_ids, condition: condition, year: params[:year], quarter: params[:quarter]
	end

    def five_star_info
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
		  	@star_infos = StarInfo.where(:workshop => Workshop.find_by(:id =>current_user.workshop_id).name,:year => @year,:quarter => @quarter)
		  	@groups = @star_infos.pluck(:group).uniq
		  	@dutys = @star_infos.pluck(:duty).uniq
		  elsif (current_user.has_role? :staradmin)  || (current_user.has_role? :superadmin) || (current_user.has_role? :leaderadmin) || (current_user.has_role? :depudy_leaderadmin)
        @star_infos = StarInfo.where(:year => @year,:quarter => @quarter)
        @workshops = @star_infos.pluck(:workshop).uniq
        groups_array = [[]]
        @workshops.each do |workshop|
        	groups = @star_infos.where(:workshop => workshop).pluck(:group).uniq
        	groups_array << groups 
        end 
        @dutys = @star_infos.pluck(:duty).uniq
	    end 
      gon.groups = groups_array
      if params[:workshop].present?
      	@star_infos = @star_infos.where(:workshop => params[:workshop])
      end 
      if params[:group].present?
      	@star_infos = @star_infos.where(:group => params[:group])
      end
      if params[:duty].present?
      	@star_infos = @star_infos.where(:duty => params[:duty])
      end
      if params[:passed_five_star].present? 
		  	@star_infos = @star_infos.where(:star => "5")
		  else 
		  	@star_infos = @star_infos.where(:star => ["5","pre_5"])
		  end  
      @star_infos = @star_infos.page(params[:page]).per(20)
      @star_infos_export = StarInfo.where(id: params[:export_stars])
		  respond_to do |format| 
		  	format.html
		  	format.xls { headers["Content-Disposition"] = 'attachment; filename="五星级岗位表.xls"'}
		  end  
    end 

    #完成本次评定：
    def finish_star_assess
    	star_confirm_status = StarConfirmStatus.find_by(:year => params[:year],:quarter => params[:quarter])
    	pre_five_star_infos = StarInfo.where(:year => params[:year],:quarter => params[:quarter],:star => "pre_5")
    	star_confirm_yes = StarConfirmStatus.find_by(:year => params[:year],:quarter => params[:quarter],:status => "1")
      if star_confirm_yes.present?
    	  @star_confirm = 1
      else 
        @star_confirm = 0
      end 
      if @star_confirm == 1
      	flash[:warning] = "#{params[:year]}年#{params[:quarter]}季度星级已评定完成，无需重复提交！"
      else
	    	if star_confirm_status.present? 
	    		star_confirm_status.update(:status => 1)
	    	else 
	    		StarConfirmStatus.create(:year => params[:year],:quarter => params[:quarter],:status => 1)
    	  end 
	    	pre_five_star_infos.update(:star => "4")
        one_to_four_star_infos = StarInfo.where(:year => params[:year], :quarter => params[:quarter], :star => 1..4).order("final_score DESC").group_by{|x| x.workshop}
        
        one_to_four_star_range = 1 - (StarRange.find_by(:name => 5).value)
        four_star_range = ((StarRange.find_by(:name => 4).value)/one_to_four_star_range).round(4)
        three_star_range = ((StarRange.find_by(:name => 3).value)/one_to_four_star_range).round(4)
        two_star_range = ((StarRange.find_by(:name => 2).value)/one_to_four_star_range).round(4)
        one_star_range = ((StarRange.find_by(:name => 1).value)/one_to_four_star_range).round(4)
        one_to_four_star_infos.each do |workshop,star_infos|
          all_count = star_infos.count
          four_star_count = (all_count * four_star_range).to_i
          three_star_count = (all_count * three_star_range).to_i
          two_star_count = (all_count * two_star_range).to_i
          star_infos.first(four_star_count).each do |star_info|
            star_info.update(:star => 4)
          end 
          star_infos.drop(four_star_count).first(three_star_count).each do |star_info| 
            star_info.update(:star => 3)
          end 
          star_infos.drop(three_star_count+four_star_count).first(two_star_count).each do |star_info|
            star_info.update(:star => 2)
          end
          star_infos.drop(four_star_count+three_star_count+two_star_count).each do |star_info|
            star_info.update(:star => 1)
          end
        end 

	    	#记录低于4星的人员
	    	descend_star_infos = StarInfo.where(:year => params[:year], :quarter => params[:quarter], :star => 1..3, :team_leader => true)
	    	descend_star_infos.each do |star_info|
	    		DescendRecord.create(:year => star_info.year, :quarter => star_info.quarter, :sal_number => star_info.sal_number, :descend_type => "低于4星")
	    	end
    	  flash[:notice] = "#{params[:year]}年#{params[:quarter]}季度星级评定完成！当前处于推荐五星状态的人员已退回四星！"
	    end 
    	redirect_back :fallback_location => five_star_info_star_infos_path
    end 
    
    #五星人员操作
    def update_five_star 
    	if params[:pass_five_star] == "yes" 
    		if params[:sal_number].present? 
	    	  @star_infos = StarInfo.where(:year => params[:year],:quarter => params[:quarter],:sal_number => params[:sal_number].keys,:star => "pre_5")
	    	  @count = @star_infos.count
	    	  @star_infos.update(:star => "5")
	    	else
	    	  @star_infos = []
	    	  @count = @star_infos.count
	    	end  
    		flash[:notice] = "您已通过#{@count}个五星人员评定！"
    	elsif params[:reback_five_star] == "yes"
    		if params[:sal_number].present? 
	    	  @star_infos = StarInfo.where(:year => params[:year],:quarter => params[:quarter],:sal_number => params[:sal_number].keys,:star => "5")
	    	  @count = @star_infos.count
	    	  @star_infos.update(:star => "pre_5")
	    	else 
	    	  @star_infos = []
	    	  @count = @star_infos.count
	    	end 
    		flash[:notice] = "您已将#{@count}个五星人员退回推荐五星！"
    	end 
    	redirect_back :fallback_location => five_star_info_star_infos_path
    end 
	protected

	def validate_search_key
       # gsub 是Ruby中正则表达式的方法，它会切换所有匹配到的部分
       @query_string = params[:q].gsub(/\\|\'|\/|\?/, "")if params[:q].present?  
    end

	def search_params
		BasicScore.ransack({ :name_or_sal_number_cont => @query_string}).result(distinct: true)
    end

    

end
