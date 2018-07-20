class User < ActiveRecord::Base
  rolify :before_add => :before_add_method #增加角色时，要做些什么
  # before_create :set_default_role

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  validates :name, presence: { message: "请填写姓名"}
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
