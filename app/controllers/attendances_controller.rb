class AttendancesController < ApplicationController
layout 'home'

	def group
		@employees = Employee.where(:id => 1..20)
	end

	def create_attendance
		
	end

	def show_modal
		@attendances = Attendance.first
		respond_to do |format|
			format.js
		end
	end

end
 