class Attendance < ApplicationRecord
	belongs_to :employee
	has_many :attendance_records
end
