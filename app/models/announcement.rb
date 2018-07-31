class Announcement < ApplicationRecord
  belongs_to :user, optional: true
  validates_presence_of :title, :content
end
