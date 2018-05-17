class Workshop < ApplicationRecord
	has_many :groups
	has_many :employees
end
