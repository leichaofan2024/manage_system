class ProductionStuffWageHead < ApplicationRecord
  validates :head_name, presence: true
  validates :head_name, uniqueness: true
  validates :production_head_name, presence: true
  validates :production_head_name, uniqueness: true
end
