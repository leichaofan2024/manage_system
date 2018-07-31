class User < ActiveRecord::Base
  rolify :before_add => :before_add_method #增加角色时，要做些什么
  # before_create :set_default_role

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  validates :name, presence: { message: "请填写姓名"}
  validates :name, uniqueness: { message: "已有其他用户使用该用户名"}
  validates :password, presence: { message: "请设置密码，最小长度为6位数字"}
  validates :password_confirmation, presence: { message: "密码不一致"}
  has_many :messages

  has_many :relative_salers

  has_many :announcements

  # 增加角色前要做些什么
  def before_add_method(role)

  end

  #设置默认权限
  # def set_default_role
  #   self.roles.first ||= Role.find_by_name('groupadmin')
  # end


end
