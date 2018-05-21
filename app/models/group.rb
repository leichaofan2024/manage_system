class Group < ApplicationRecord
	belongs_to :workshop
	has_many :attendance_counts
	has_many :employees, class_name: "EmpBasicInfo"
end
