class User < ActiveRecord::Base
  rolify :before_add => :before_add_method #增加角色时，要做些什么

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  validates :name, presence: true
  validates :name, uniqueness: true
  has_many :messages


  # 增加角色前要做些什么
  def before_add_method(role)

  end


end
