class Group < ApplicationRecord
	belongs_to :workshop
	has_many :attendance_counts
	has_many :employees, class_name: "EmpBasicInfo"

	#所有在使用的班组
  	scope :current, -> { where(status: "1")}

end
