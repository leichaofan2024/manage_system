class Workshop < ApplicationRecord
	has_many :groups
	has_many :attendance_counts
	has_many :employees, class_name: "EmpBasicInfo"
	has_many :annual_holiday_plans


	def self.create_workshop
		Workshop.create(name: "啦啦啦班组")
	end
end
