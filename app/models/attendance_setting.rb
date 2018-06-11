class AttendanceSetting < ApplicationRecord
  validates :count, :presence: true
  validates :vacation, :presence: true
end
