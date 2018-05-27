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
		holiday = AnnualHolidayPlan.find_by(:workshop => params[:workshop], :year => Time.now.year, :work_type => params[:work_type]) || AnnualHolidayPlan.new
		holiday.update(:workshop_id => params[:workshop].to_i, :year => Time.now.year, :work_type => params[:work_type], params[:input_name] => params[:number])
		redirect_back(fallback_location: annual_holidays_path)
	end

end
