class MainDrivingStuffHead < ApplicationRecord
  validates :head_name, presence: true
  validates :head_name, uniqueness: true
  validates :main_head_name, presence: true
  validates :main_head_name, uniqueness: true
end
