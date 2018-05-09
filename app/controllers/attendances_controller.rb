class AttendancesController < ApplicationController
layout 'home'

	def group
		@employees = Employee.where(:id => 1..20)
	end

end
 