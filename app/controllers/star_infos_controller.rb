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

	# def filter
	# 	if params[:workshop] == "--选择车间--"
	# 		params[:workshop] = nil
	# 	end
	# 	if params[:group] == "--选择班组--"
	# 		params[:group] = nil
	# 	end
	# 	# 配置车间班组筛选框数据
	# 	workshop = StarInfo.pluck("workshop").uniq
	# 	@group = [["--选择班组--"]]
	#     workshop.each do |name|
	#       @group << StarInfo.where(workshop: name).pluck(:group).uniq
	#     end
	#     gon.group_name = @group
	# 	@workshop_names = StarInfo.pluck("workshop").uniq
	# 	@year = params[:year]
	# 	@quarter = params[:quarter]
	# 	@type = params[:type]
	# 	quarter_month = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]]
	# 	quarter_month.each do |i|
	# 		if i.include?(Time.now.month)
	# 			@current_quarter = (quarter_month.index(i) + 1)
	# 		end
	# 	end
	# 	if (@year.present?) || (@quarter.present?)
	# 		condition = ".where(year: @year, quarter: @quarter"
	# 	else
	# 		condition = ".where(year: Time.now.year, quarter: @current_quarter"
	# 	end
	#     if params[:workshop].present?
	#       condition += ", workshop: '#{params[:workshop]}'"
	#     end
	#     if params[:group].present?
	#       condition += ", group: '#{params[:group]}'"
	#     end
	#     if params[:duty].present?
	#       condition += ", duty: '#{params[:duty]}'"
	#     end
	#     if params[:star].present?
	#       condition += ", star: '#{params[:star]}'"
	#     end
	#     condition += ")"
	#     @scores = eval("StarInfo#{condition}")
	# 	render :action => "all_star_info"
	# end

	protected

	def validate_search_key
       # gsub 是Ruby中正则表达式的方法，它会切换所有匹配到的部分
       @query_string = params[:q].gsub(/\\|\'|\/|\?/, "")if params[:q].present?  
    end

	def search_params
		BasicScore.ransack({ :name_or_sal_number_cont => @query_string}).result(distinct: true)
    end

    

end
