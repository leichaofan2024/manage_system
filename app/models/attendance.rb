class Attendance < ApplicationRecord
	belongs_to :employee
	has_many :attendance_records

	#考勤表与角色表的关系
	resourcify

	scope :search_records, -> (params){self.search(params).records }

end
