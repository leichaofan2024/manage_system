class AttendancesController < ApplicationController
layout 'home'

	def group
	  @days = 1..31
		@employees = Employee.where(:id => 1)
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
		@employees = Employee.where(:id => 8513..8524)
		@vacation_names = VacationCategory.pluck("vacation_name").uniq
		@categories = VacationCategory.all
		@vacation = {}
		@categories.each do |category|
			@vacation[category.vacation_shortening] = category.vacation_code
		end
	end

	def duan
		@employees = Employee.where(:id => 8513..8524)
	end


end
