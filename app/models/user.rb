class User < ActiveRecord::Base
  rolify :before_add => :before_add_method
  after_create :assign_default_role

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  validates :name, presence: true

  def before_add_method(role)

  end

  def assign_default_role
    self.add_role(:newuser) if self.roles.blank?
  end


end
