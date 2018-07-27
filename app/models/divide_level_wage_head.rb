class DivideLevelWageHead < ApplicationRecord
  validates :head_name, presence: true
  validates :head_name, uniqueness: true
  validates :divide_head_name, presence: true
  validates :divide_head_name, uniqueness: true
end
