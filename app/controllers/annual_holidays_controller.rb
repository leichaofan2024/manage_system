class AnnualHolidaysController < ApplicationController
	layout 'home'

	def index
		if (current_user.has_role? :workshopadmin) or (current_user.has_role? :organsadmin)
			@employees = Employee.where(workshop: "#{Workshop.find_by(name: current_user.name).id}")
		elsif (current_user.has_role? :attendance_admin) or (current_user.has_role? :superadmin)
			@employees = Employee.all
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

	def create_holiday
		month = params[:month]
		holiday = AnnualHoliday.find_by(:employee_id => params[:employee]) || AnnualHoliday.new
		holiday.update(:employee_id => params[:employee], :month => params[:month], :holiday_days => params[:holiday_days])
		redirect_back(fallback_location: annual_holidays_path)
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

end
