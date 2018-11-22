class AnnualHolidaysController < ApplicationController
	layout 'home'

	def index
		if (current_user.has_role? :workshopadmin) or (current_user.has_role? :organsadmin)
			@employees = Employee.current.where(workshop: "#{current_user.workshop_id}")
		elsif (current_user.has_role? :attendance_admin) or (current_user.has_role? :superadmin)
			@employees = Employee.current.order("id ASC").page(params[:page]).per(20)
		end
	end

	def holiday_modal
		@work_type = params[:work_type]
		@number = params[:number]
		@workshop = params[:workshop]
		@id = params[:id]
		respond_to do |format|
			format.js
		end
	end

	def create_holiday_plan
		if params[:number].present?
			holiday = AnnualHolidayPlan.find_by(:workshop => params[:workshop], :year => Time.now.year, :work_type => params[:work_type]) || AnnualHolidayPlan.new
			holiday.update(:workshop_id => params[:workshop].to_i, :year => Time.now.year, :work_type => params[:work_type], params[:input_name] => params[:number])
		end
		if params[:status].present?
			if current_user.has_role? :workshopadmin
				hoiday_plans = AnnualHolidayPlan.where(:workshop_id => current_user.workshop_id,:year => Time.now.year)
			elsif (current_user.has_role? :organsadmin)
				hoiday_plans = AnnualHolidayPlan.where(:orgnization_id => current_user.group_id,:year => Time.now.year)
			end 
			if hoiday_plans.present?
				message_array = Array.new 
				hoiday_plans.each do |holiday| 
					if (holiday.this_year_people_number.to_i == holiday.five_days.to_i + holiday.ten_days.to_i + holiday.fifteen_days.to_i) && (holiday.holiday_days.to_i == holiday.January_plan_number.to_i + holiday.February_plan_number.to_i + holiday.March_plan_number.to_i + holiday.April_plan_number.to_i + holiday.May_plan_number.to_i + holiday.June_plan_number.to_i + holiday.July_plan_number.to_i + holiday.August_plan_number.to_i + holiday.September_plan_number.to_i + holiday.October_plan_number.to_i + holiday.November_plan_number.to_i + holiday.December_plan_number.to_i)
					else
						if AnnualHolidayWorkType.find_by(:id => holiday.work_type).present?
						  work_type = AnnualHolidayWorkType.find_by(:id => holiday.work_type).work_type
						  message_array << work_type
					    end 
					end
				end 
				if message_array.present?
				  flash[:alert] = "上报失败！#{message_array}项总数核对有误，请检查！"
				else 
				  hoiday_plans.update(:status => "yes")
				  flash[:notice] = "#{Time.now.year}年年休假计划上报成功！"
				end 
			else
				flash[:alert] = "没有数据，请填写完成后再上报！"
			end
		end
		redirect_back(fallback_location: annual_holidays_path)
	end

	def duan_holiday_plan
		useless_columns = ["id", "workshop_id", "work_type","created_at", "updated_at", "year", "status"]
		@columns = AnnualHolidayPlan.column_names - useless_columns
		@workshops = Workshop.current.where(:id => AnnualHolidayPlan.where(:status => "车间填写完毕").pluck("workshop_id"))
		@worktypes = AnnualHolidayWorkType.all
		@duan = params[:duan]
		if params[:workshop].present?
			@workshop = params[:workshop]
		end
	end

	def update_holiday
		attendance_counts = AttendanceCount.where(:year => Time.now.year, vacation_code: ["f", "g"])
		attendance_counts.pluck("employee_id").uniq.each do |employee|
			(1..12).each do |month|
				if attendance_counts.find_by(employee_id: employee, month: month).present?
					sum = attendance_counts.find_by(employee_id: employee, month: month, vacation_code: "f").count + attendance_counts.find_by(employee_id: employee, month: month, vacation_code: "g").count
				end
				annual_holiday = AnnualHoliday.find_by(employee_id: employee, month: month, year: Time.now.year) || AnnualHoliday.new
				annual_holiday.update(employee_id: employee, month: month, year: Time.now.year, holiday_days: sum)
			end
		end
		flash["notice"] = "休假更新成功"
		redirect_back(fallback_location: holiday_fulfill_detail_annual_holidays_path)
	end

	def holiday_fulfill_detail
		@employees = Employee.current.page(params[:page]).per(20)
		workshop = Workshop.current.pluck("name")
	    @group = [["--选择省份--"]]
	    workshop.each do |name|
	      @group << Group.current.where(:workshop_id => Workshop.current.find_by(:name => name).id).pluck("name","id")
	    end
	    gon.group_name = @group
		@years = AnnualHoliday.pluck("year").uniq
		@workshop_names = Workshop.current.pluck("name","id")
	end

	def filter
		@workshops = Workshop.current
		@workshop_names = @workshops.pluck("name","id")
		@groups = Group.current
		@years = AnnualHoliday.pluck("year").uniq
		if !params[:workshop].present? && !params[:group].present? && !params[:year].present?
			flash[:alert] = "请先选择筛选条件哦"
			redirect_to holiday_fulfill_detail_annual_holidays_path
		else
			if params[:year].present?
				@params_year = params[:year]
				if (params[:workshop].present?) && (params[:group].blank?)
					@employees = Employee.current.where(:workshop => params[:workshop]).page(params[:page]).per(20)
				elsif (params[:workshop].blank?) && (params[:group].present?)
					@employees = Employee.current.where(:group => params[:group]).page(params[:page]).per(20)
				elsif (params[:workshop].present?) && (params[:group].present?)
					@employees = Employee.current.where(:workshop => params[:workshop], :group => params[:group]).page(params[:page]).per(20)
				elsif (params[:workshop].blank?) && (params[:group].blank?)
					@employees = Employee.current.page(params[:page]).per(20)
				end
				render action: "holiday_fulfill_detail"
			else
				if (params[:workshop].present?) && (params[:group].blank?)
					@employees = Employee.current.where(:workshop => params[:workshop]).page(params[:page]).per(20)
				elsif (params[:workshop].blank?) && (params[:group].present?)
					@employees = Employee.current.where(:group => params[:group]).page(params[:page]).per(20)
				elsif (params[:workshop].present?) && (params[:group].present?)
					@employees = Employee.current.where(:workshop => params[:workshop], :group => params[:group]).page(params[:page]).per(20)
				end
				render action: "holiday_fulfill_detail"
			end
		end

	end

	def holiday_fulfillment_rate
		@workshops = Workshop.current
	end

	def group_holiday_fulfill
		@employees = Employee.current.where(:group => current_user.group_id)
	end

end
