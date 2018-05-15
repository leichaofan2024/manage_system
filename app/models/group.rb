class Group < ApplicationRecord
	belongs_to :workshop, :foreign_key => "workshop_id"
end
