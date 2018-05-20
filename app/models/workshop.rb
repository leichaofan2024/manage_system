class Workshop < ApplicationRecord
	has_many :groups
	has_many :attendance_counts
end
