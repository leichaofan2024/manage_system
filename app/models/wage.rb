class Wage < ApplicationRecord
	belongs_to :employee, :foreign_key => "employee_id"
end
