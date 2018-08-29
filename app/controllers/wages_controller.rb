class WagesController < ApplicationController
	layout 'home'
  def index
	end


	def import_wage
		if params[:year].present? && params[:month].present?
			@year = params[:year].to_i
			@month = params[:month].to_i
		else
			wage_year_month_array = Wage.pluck(:year,:month).uniq.last
			if wage_year_month_array.present?
				@year = wage_year_month_array[0]
				@month = wage_year_month_array[1]
			else
				@year = Time.now.year
				@month = Time.now.month
			end
		end
		@wages = Wage.where(:year => @year, :month => @month).page(params[:page]).per(20)
    #下载表格配置
    @export_wages = Wage.where(:year => @year, :month => @month)
    respond_to do |format|
      format.html
      format.xls { headers["Content-Disposition"] = 'attachment; filename="工资表.xls"'}
    end
	end


  # 删除工资表
  def delete_wage
		@wages = Wage.where(:year => params[:year], :month => params[:month])
		@wages.delete_all
		redirect_to import_wage_wages_path
		flash[:notice] = "已成功删除#{params[:year]}年#{params[:month]}月工资表！"
	end

	#上传表格
  def import_table
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      import_message = Wage.import_table(params[:file],params[:year],params[:month])
      if import_message["head"].present?
        flash[:alert] = import_message["head"]
			elsif import_message["year_month"].present?
				flash[:alert] = import_message["year_month"]
			else
				flash[:notice] = "上传成功"
			end
    end
    redirect_to import_wage_wages_path
  end

  def create_header
    if WageHeader.find_by(header: params[:header]).present?
      flash[:alert] = "您填写的表头已存在"
    else
      WageHeader.create(header: params[:header])
      flash[:notice] = "新增成功"
    end
    redirect_to import_wage_wages_path
  end

  def edit_header
    wage_header = WageHeader.find_by(header: params[:before_header])
    wage_header.update(header: params[:after_header])
    flash[:notice] = "修改成功"
    redirect_to import_wage_wages_path
  end

	#每项具体人员信息
  def employees_wage_show
		if params[:category] = "divide"
      @line_content = DivideLevelWage.find(params[:content_id])
			@formula = @line_content.formula
		elsif params[:category] = "high"
			@line_content = HighSpeedRailStuff.find(params[:content_id])
			@formula = @line_content.formula
		elsif params[:category] = "main"
			@line_content = MainDrivingStuff.find(params[:content_id])
			@formula = @line_content.formula
		elsif params[:category] = "production"
			@line_content = ProductionStuffWage.find(params[:content_id])
			@formula = @line_content.formula
		end
    if params[:sal_number].present? && params[:type].present?
			if params[:type] == "add_people"

				if @formula["reduce_people"].present?
					if @formula["reduce_people"].include?(params[:sal_number])
            @formula["reduce_people"] -= [params[:sal_number]]
				  else
						if !@formula["add_people"].present?
							@formula["add_people"] = []
						end
						@formula["add_people"] = (@formula["add_people"] + [params[:sal_number]]).uniq
					end
				else
					if !@formula["add_people"].present?
						@formula["add_people"] = []
					end
					@formula["add_people"] = (@formula["add_people"] + [params[:sal_number]]).uniq
				end
			elsif params[:type] == "reduce_people"
				if @formula["add_people"].present?
					if @formula["add_people"].include?(params[:sal_number])
          	@formula["add_people"] -= [params[:sal_number]]
					else
						if !@formula["reduce_people"].present?
							@formula["reduce_people"] = []
						end
						@formula["reduce_people"] = (@formula["reduce_people"] + [params[:sal_number]]).uniq
					end
				else
					if !@formula["reduce_people"].present?
						@formula["reduce_people"] = []
					end
          @formula["reduce_people"] = (@formula["reduce_people"] + [params[:sal_number]]).uniq
				end
			end
			@line_content.update(:formula => @formula)
			add_people = Employee.current.where(:sal_number => @formula["add_people"])
			@employees = Employee.current.where(@formula.delete_if{|key,value| ["add_people","reduce_people"].include?(key) }) | add_people
			if params[:category] = "divide"
				@formula = DivideLevelWage.find(params[:content_id]).formula
			elsif params[:category] = "high"
				@formula = HighSpeedRailStuff.find(params[:content_id]).formula
			elsif params[:category] = "main"
				@formula = MainDrivingStuff.find(params[:content_id]).formula
			elsif params[:category] = "production"
				@formula = ProductionStuffWage.find(params[:content_id]).formula
			end
			redirect_to employees_wage_show_wages_path(:category => params[:category],:content_id => params[:content_id],:content_name => params[:content_name])
		end
    add_people = Employee.current.where(:sal_number => @formula["add_people"])
		@employees = Employee.current.where(@formula.delete_if{|key,value| ["add_people","reduce_people"].include?(key) }) | add_people
		if params[:category] = "divide"
			@formula = DivideLevelWage.find(params[:content_id]).formula
		elsif params[:category] = "high"
			@formula = HighSpeedRailStuff.find(params[:content_id]).formula
		elsif params[:category] = "main"
			@formula = MainDrivingStuff.find(params[:content_id]).formula
		elsif params[:category] = "production"
			@formula = ProductionStuffWage.find(params[:content_id]).formula
		end
	end

  #统计表方法：
  def kuaizhao_index
		if params[:year].present? && params[:month].present?
			@year = params[:year].to_i
			@month = params[:month]
		elsif params[:year].present? && !params[:month].present?
			@year = params[:year].to_i
			@month = KuaizhaoContent.where(:year => @year).pluck(:month).uniq
		else
			@year = Time.now.year
			@month = KuaizhaoContent.where(:year => @year).pluck(:month).uniq
		end
    @years = KuaizhaoContent.pluck("year").uniq
    @months = KuaizhaoContent.pluck("month").uniq



	  @kuaizhao_contents = KuaizhaoContent.where(:category => params[:category],:year => @year, :month =>@month)
		@kuaizhao_headers = KuaizhaoHeader.where(:category => params[:category],:year => @year, :month =>@month)
		max_month = @kuaizhao_contents.pluck(:month).max
    @column_array = KuaizhaoHeader.where(:category => params[:category],:year => @year, :month =>max_month).pluck(:header_name).uniq
		@line_name_array = KuaizhaoContent.where(:category => params[:category],:year => @year, :month =>max_month).pluck(:name).uniq
	end

# 快照功能
	def create_kuaizhao
		# wage_year_month_array = Wage.pluck(:year,:month).uniq
		# if wage_year_month_array.present?
		# 	if params[:year].present? && params[:month].present?
		# 		if wage_year_month_array.include?([params[:year].to_i,params[:month].to_i])
		# 			@year = params[:year]
		# 			@month = params[:month]
		# 		end
		# 	else
		# 		wage_year_month_last = wage_year_month_array.last
		# 		@year = wage_year_month_last[0]
		# 		@month = wage_year_month_last[1]
		# 	end
		# end
    @year = params[:year].to_i
		@month = params[:month].to_i

    @kuaizhao = KuaizhaoHeader.where(:category => params[:category],:year => @year, :month => @month)
    if !@kuaizhao.present?
			if params[:category] == "divide" && @year.present? && @month.present?
				divide_head_hash = DivideLevelWageHead.pluck(:head_name,:divide_head_name).to_h
				#统计记录循环：
		    DivideLevelWage.all.each do |level|
				  level_formula = level.formula
				  if level_formula.keys.include?("age")
					  level_age_range = []
					  level_formula["age"].each do |value|
				     	level_age_range<< value.to_i
					  end
					  level_formula["age"] = (level_age_range.min..level_age_range.max)
				  end
					@employee_people = Employee.current.where(level_formula)
			    wage_people = Wage.where(Wage.head_transfer.index("工资号") => @employee_people.pluck("sal_number"),:year => @year, :month => @month)

					kuaizhao_content_hash = Hash.new
					kuaizhao_names = KuaizhaoHeader.where(:category => params[:category],:year => @year, :month => @month).pluck(:header_name)
	        #计算每一行的数据：
					DivideLevelWageHead.all.each do |head|
						if !kuaizhao_names.include?(head.head_name)
							KuaizhaoHeader.create( :content_name => head.divide_head_name , :header_name => head.head_name,
								                     :formula => head.formula,:category => params[:category],:year => @year,:month => @month)
						end
						head_formula = head.formula.delete_if{|key,value| ["average","final_period","per_capita"].include?(key) }
						if !head_formula.values.include?("1") && !head_formula.values.include?("2")
						  if head_formula.keys.include?("age")
							  age_range = []
					 	    head_formula["age"].each do |value|
							    age_range<< value.to_i
							  end
							  head_formula["age"] = (age_range.min..age_range.max)
						  end
						  kuaizhao_content_hash[head.divide_head_name]= @employee_people.where(head_formula).count
						else
							form_cel_value = 0
							head_formula.keys.each do |key|
								if head_formula[key] == "1"
									 form_cel_value += wage_people.sum(key).to_i
								elsif head_formula[key] == "2"
									 form_cel_value -= wage_people.sum(key).to_i
								end
							end
							kuaizhao_content_hash[head.divide_head_name] = form_cel_value
						end
					end
					#一行的数据计算完毕/
					kuaizhao_content_hash["name"] = level.name
					kuaizhao_content_hash["formula"] = level.formula
					kuaizhao_content_hash["category"] = params[:category]
					kuaizhao_content_hash["year"] = @year
					kuaizhao_content_hash["month"] = @month
					#生成一条快照记录：
					KuaizhaoContent.create(kuaizhao_content_hash)
					#生成一条快照记录结束
				end
				#统计记录循环结束
	      flash[:notice] = "#{@year}年#{@month}月‘铁路企业分层次人员工资情况统计表’快照已生成！"

			elsif params[:category] == "production" && @year.present? && @month.present?
				divide_head_hash = ProductionStuffWageHead.pluck(:head_name,:production_head_name).to_h
				#统计记录循环：
		    ProductionStuffWage.all.each do |level|
				  level_formula = level.formula
				  if level_formula.keys.include?("age")
					  level_age_range = []
					  level_formula["age"].each do |value|
				     	level_age_range<< value.to_i
					  end
					  level_formula["age"] = (level_age_range.min..level_age_range.max)
				  end
					@employee_people = Employee.current.where(level_formula)
			    wage_people = Wage.where(Wage.head_transfer.index("工资号") => @employee_people.pluck("sal_number"),:year => @year, :month => @month)

					kuaizhao_content_hash = Hash.new
					kuaizhao_names = KuaizhaoHeader.where(:category => params[:category],:year => @year, :month => @month).pluck(:header_name)
	        #计算每一行的数据：
					ProductionStuffWageHead.all.each do |head|
						if !kuaizhao_names.include?(head.head_name)
							KuaizhaoHeader.create( :content_name => head.production_head_name , :header_name => head.head_name,
								                     :formula => head.formula,:category => params[:category],:year => @year,:month => @month)
						end
						head_formula = head.formula.delete_if{|key,value| ["average","final_period","per_capita"].include?(key) }
						if !head_formula.values.include?("1") && !head_formula.values.include?("2")
						  if head_formula.keys.include?("age")
							  age_range = []
					 	    head_formula["age"].each do |value|
							    age_range<< value.to_i
							  end
							  head_formula["age"] = (age_range.min..age_range.max)
						  end
						  kuaizhao_content_hash[head.production_head_name]= @employee_people.where(head_formula).count
						else
							form_cel_value = 0
							head_formula.keys.each do |key|
								if head_formula[key] == "1"
									 form_cel_value += wage_people.sum(key).to_i
								elsif head_formula[key] == "2"
									 form_cel_value -= wage_people.sum(key).to_i
								end
							end
							kuaizhao_content_hash[head.production_head_name] = form_cel_value
						end
					end
					#一行的数据计算完毕/
					kuaizhao_content_hash["name"] = level.name
					kuaizhao_content_hash["formula"] = level.formula
					kuaizhao_content_hash["category"] = params[:category]
					kuaizhao_content_hash["year"] = @year
					kuaizhao_content_hash["month"] = @month
					#生成一条快照记录：
					KuaizhaoContent.create(kuaizhao_content_hash)
					#生成一条快照记录结束
				end
				#统计记录循环结束
	      flash[:notice] = "#{@year}年#{@month}月‘运输站段生产人员人数和报酬统计表’快照已生成！"

			elsif params[:category] == "main" && @year.present? && @month.present?
				divide_head_hash = MainDrivingStuffHead.pluck(:head_name,:main_head_name).to_h
				#统计记录循环：
				MainDrivingStuff.all.each do |level|
					level_formula = level.formula
					if level_formula.keys.include?("age")
						level_age_range = []
						level_formula["age"].each do |value|
							level_age_range<< value.to_i
						end
						level_formula["age"] = (level_age_range.min..level_age_range.max)
					end
					@employee_people = Employee.current.where(level_formula)
					wage_people = Wage.where(Wage.head_transfer.index("工资号") => @employee_people.pluck("sal_number"),:year => @year, :month => @month)

					kuaizhao_content_hash = Hash.new
					kuaizhao_names = KuaizhaoHeader.where(:category => params[:category],:year => @year, :month => @month).pluck(:header_name)
					#计算每一行的数据：
					MainDrivingStuffHead.all.each do |head|
						if !kuaizhao_names.include?(head.head_name)
							KuaizhaoHeader.create( :content_name => head.main_head_name , :header_name => head.head_name,
																		 :formula => head.formula,:category => params[:category],:year => @year,:month => @month)
						end
						head_formula = head.formula.delete_if{|key,value| ["average","final_period","per_capita"].include?(key) }
						if !head_formula.values.include?("1") && !head_formula.values.include?("2")
							if head_formula.keys.include?("age")
								age_range = []
								head_formula["age"].each do |value|
									age_range<< value.to_i
								end
								head_formula["age"] = (age_range.min..age_range.max)
							end
							kuaizhao_content_hash[head.main_head_name]= @employee_people.where(head_formula).count
						else
							form_cel_value = 0
							head_formula.keys.each do |key|
								if head_formula[key] == "1"
									 form_cel_value += wage_people.sum(key).to_i
								elsif head_formula[key] == "2"
									 form_cel_value -= wage_people.sum(key).to_i
								end
							end
							kuaizhao_content_hash[head.main_head_name] = form_cel_value
						end
					end
					#一行的数据计算完毕/
					kuaizhao_content_hash["name"] = level.name
					kuaizhao_content_hash["formula"] = level.formula
					kuaizhao_content_hash["category"] = params[:category]
					kuaizhao_content_hash["year"] = @year
					kuaizhao_content_hash["month"] = @month
					#生成一条快照记录：
					KuaizhaoContent.create(kuaizhao_content_hash)
					#生成一条快照记录结束
				end
				#统计记录循环结束
				flash[:notice] = "#{@year}年#{@month}月‘主要行车工种情况统计表’快照已生成！"
			elsif params[:category] == "high" && @year.present? && @month.present?
				divide_head_hash = HighSpeedRailStuffHead.pluck(:head_name,:high_head_name).to_h
				#统计记录循环：
				HighSpeedRailStuff.all.each do |level|
					level_formula = level.formula
					if level_formula.keys.include?("age")
						level_age_range = []
						level_formula["age"].each do |value|
							level_age_range<< value.to_i
						end
						level_formula["age"] = (level_age_range.min..level_age_range.max)
					end
					@employee_people = Employee.current.where(level_formula)
					wage_people = Wage.where(Wage.head_transfer.index("工资号") => @employee_people.pluck("sal_number"),:year => @year, :month => @month)

					kuaizhao_content_hash = Hash.new
					kuaizhao_names = KuaizhaoHeader.where(:category => params[:category],:year => @year, :month => @month).pluck(:header_name)
					#计算每一行的数据：
					HighSpeedRailStuffHead.all.each do |head|
						if !kuaizhao_names.include?(head.head_name)
							KuaizhaoHeader.create( :content_name => head.high_head_name , :header_name => head.head_name,
																		 :formula => head.formula,:category => params[:category],:year => @year,:month => @month)
						end
						head_formula = head.formula.delete_if{|key,value| ["average","final_period","per_capita"].include?(key) }
						if !head_formula.values.include?("1") && !head_formula.values.include?("2")
							if head_formula.keys.include?("age")
								age_range = []
								head_formula["age"].each do |value|
									age_range<< value.to_i
								end
								head_formula["age"] = (age_range.min..age_range.max)
							end
							kuaizhao_content_hash[head.high_head_name]= @employee_people.where(head_formula).count
						else
							form_cel_value = 0
							head_formula.keys.each do |key|
								if head_formula[key] == "1"
									 form_cel_value += wage_people.sum(key).to_i
								elsif head_formula[key] == "2"
									 form_cel_value -= wage_people.sum(key).to_i
								end
							end
							kuaizhao_content_hash[head.high_head_name] = form_cel_value
						end
					end
					#一行的数据计算完毕/
					kuaizhao_content_hash["name"] = level.name
					kuaizhao_content_hash["formula"] = level.formula
					kuaizhao_content_hash["category"] = params[:category]
					kuaizhao_content_hash["year"] = @year
					kuaizhao_content_hash["month"] = @month
					#生成一条快照记录：
					KuaizhaoContent.create(kuaizhao_content_hash)
					#生成一条快照记录结束
				end
				#统计记录循环结束
				flash[:notice] = "#{@year}年#{@month}月高铁岗位人员情况统计表快照已生成！"
			else
				flash[:alert] = "#{@year}年#{@month}月还未上传工资表！"
			end
	  else
			flash[:alert] = "#{@year}年#{@month}月快照已存在，请勿重复快照！"
		end

		if params[:category] == "divide"
		  redirect_to divide_level_wages_path
	  elsif params[:category] == "production"
			redirect_to production_stuff_wages_path
		elsif params[:category] == "main"
			redirect_to main_driving_stuffs_path
		else params[:category] == "high"
			redirect_to high_speed_rail_stuffs_path
		end
	end
#快照功能结束


end
