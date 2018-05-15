class AttendanceRecord < ApplicationRecord
	belongs_to :attendance, :foreign_key => "attendance_id"
end
