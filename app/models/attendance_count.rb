class AttendanceCount < ApplicationRecord
	belongs_to :workshop, :foreign_key => "workshop_id"
	belongs_to :group, :foreign_key => "group_id"
	belongs_to :employee, :foreign_key => "employee_id"
end
