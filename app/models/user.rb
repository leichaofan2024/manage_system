class User < ActiveRecord::Base
  rolify :before_add => :before_add_method #增加角色时，要做些什么
  # after_create :assign_default_role #创建用户后分配默认角色

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  validates :name, presence: true


  # 增加角色前要做些什么
  def before_add_method(role)

  end

  #分配默认角色
  # def assign_default_role
  #   self.add_role(:newuser) if self.roles.blank?
  # end


end
