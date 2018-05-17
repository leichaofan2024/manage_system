class Workshop < ApplicationRecord
	has_many :groups
	has_many :employees
	has_many :emp_basic_infos
end
