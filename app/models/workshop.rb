class Workshop < ApplicationRecord
	has_many :groups
	has_many :attendance_counts
	has_many :employees, class_name: "EmpBasicInfo"
	has_many :annual_holiday_plans

	#所有在使用的车间
  	scope :current, -> { where(status: "1")}

	def self.create_workshop
		Workshop.create(name: "啦啦啦班组")
	end
end
