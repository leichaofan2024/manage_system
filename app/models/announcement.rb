class Announcement < ApplicationRecord
  belongs_to :user, optional: true
end
