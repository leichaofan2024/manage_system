class AnnualHolidaysController < ApplicationController
	layout 'home'

	def index
		if (current_user.has_role? :workshopadmin) or (current_user.has_role? :organsadmin)
			@employees = Employee.current.where(workshop: "#{Workshop.find_by(name: current_user.name).id}")
		elsif (current_user.has_role? :attendance_admin) or (current_user.has_role? :superadmin)
			@employees = Employee.current.order("id ASC").page(params[:page]).per(20)
		end
	end

	def holiday_modal
		@work_type = params[:work_type]
		@number = params[:number]
		@workshop = params[:workshop]
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
			if holiday.present?
				if (holiday.this_year_people_number == holiday.five_days + holiday.ten_days + holiday.fifteen_days) && (holiday.this_year_people_number == holiday.January_plan_number + holiday.February_plan_number + holiday.March_plan_number + holiday.April_plan_number + holiday.May_plan_number + holiday.June_plan_number + holiday.July_plan_number + holiday.August_plan_number + holiday.September_plan_number + holiday.October_plan_number + holiday.November_plan_number + holiday.December_plan_number)
					holiday.update(:status => "车间填写完毕")
				else
					flash[:alert] = "确认失败，请核对您的总数"
				end
			else
				flash[:alert] = "确认失败，请核对您的总数"
			end
		end
		redirect_back(fallback_location: annual_holidays_path)
	end

	def duan_holiday_plan
		@workshops = Workshop.where(:id => AnnualHolidayPlan.where(:status => "车间填写完毕").pluck("workshop_id"))
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
		@employees = Employee.current.where(id: 300..400)
		@workshops = Workshop.all
		@groups = Group.all
		@years = AnnualHoliday.pluck("year").uniq
	end

	def filter
		@workshops = Workshop.all
		@groups = Group.all
		@years = AnnualHoliday.pluck("year").uniq
		if params[:year].present?
			@params_year = params[:year]
			if (params[:workshop].present?) && (params[:group].blank?)
				@employees = Employee.current.where(:workshop => params[:workshop])
			elsif (params[:workshop].blank?) && (params[:group].present?)
				@employees = Employee.current.where(:group => params[:group])
			elsif (params[:workshop].present?) && (params[:group].present?)
				@employees = Employee.current.where(:workshop => params[:workshop], :group => params[:group])
			end
		else
			if (params[:workshop].present?) && (params[:group].blank?)
				@employees = Employee.current.where(:workshop => params[:workshop])
			elsif (params[:workshop].blank?) && (params[:group].present?)
				@employees = Employee.current.where(:group => params[:group])
			elsif (params[:workshop].present?) && (params[:group].present?)
				@employees = Employee.current.where(:workshop => params[:workshop], :group => params[:group])
			end
		end
		render action: "holiday_fulfill_detail"
	end

	def holiday_fulfillment_rate
		@workshops = Workshop.all
	end

	def group_holiday_fulfill
		group_name = current_user.name.split("-")[1] 
		@employees = Employee.current.where(:group => Group.find_by(:name => group_name).id)
	end

end
