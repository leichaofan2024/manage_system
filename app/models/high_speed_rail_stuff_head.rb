class HighSpeedRailStuffHead < ApplicationRecord
  validates :head_name, presence: true
  validates :head_name, uniqueness: true
  validates :high_head_name, presence: true
  validates :high_head_name, uniqueness: true
end
