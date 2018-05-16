class AttendancesController < ApplicationController
layout 'home'

	def group
	  	@days = 1..31
		@employees = Employee.all
		@vacation_names = VacationCategory.pluck("vacation_name").uniq
		@categories = VacationCategory.all
		@vacation = {}
		@categories.each do |category|
			@vacation[category.vacation_shortening] = category.vacation_code
		end
	end

	def create_attendance
		@attendance = Attendance.find_by(:employee_id => params[:employee_id])
		a = @attendance.month_attendances.split('')
		a[params[:day].to_i] = params[:code]
		b = a.join('')
		@attendance.update(:month_attendances => b)
		@attendance.save
		redirect_to group_attendances_path
	end

	def show_modal
		@day_number = params[:day_number]
		@categories = VacationCategory.all
		@employee_id = params[:employee_id]
		@vacation = {}
		@categories.each do |category|
			@vacation[category.vacation_shortening] = category.vacation_code
		end
		respond_to do |format|
			format.js
		end
	end

	def workshop
		@workshop = Workshop.find_by(:name => current_user.name)
		@groups = @workshop.groups
		@click_group = params[:group]

		if params[:group].present?
			@status = AttendanceStatus.find_by(:group_id => params[:group])
			@employees = Employee.where(:workshop => params[:workshop], :group => params[:group])
		else
			@employees = Employee.where(:workshop => @workshop)
		end
		@vacation_names = VacationCategory.pluck("vacation_name").uniq
		@categories = VacationCategory.all
		@vacation = {}
		@categories.each do |category|
			@vacation[category.vacation_shortening] = category.vacation_code
		end
	end

	def verify
		@attendance_status = AttendanceStatus.find_by(:group_id => params[:click_group])
		@attendance_status.update(:status => "车间已审核")
		redirect_back(fallback_location: workshop_attendances_path)
	end

	def duan
		@employees = Employee.where(:id => 1..12)
	end


end
