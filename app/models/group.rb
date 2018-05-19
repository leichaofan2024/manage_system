class Group < ApplicationRecord
	belongs_to :workshop
	has_many :attendance_counts
end
