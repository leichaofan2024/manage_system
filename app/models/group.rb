class Group < ApplicationRecord
	belongs_to :workshop
	has_many :attendance_counts
	has_many :employees, class_name: "EmpBasicInfo"

	validates :name, presence: { message: "请填写班组名称"}
  validates :name, uniqueness: { message: "重复的班组名"}
	#所有在使用的班组
  scope :current, -> { where(status: "1")}

end
