class Workshop < ApplicationRecord
	has_many :groups
	has_many :attendance_counts
	has_many :employees, class_name: "EmpBasicInfo"

	validates :name, presence: { message: "请填写车间名称"}
  validates :name, uniqueness: { message: "重复的车间名"}
	#所有在使用的车间
  scope :current, -> { where(status: "1")}

end
