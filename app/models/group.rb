class Group < ApplicationRecord
	belongs_to :workshop, :foreign_key => "workshop_id"
	has_many :employees
	has_many :emp_basic_infos
	
end
