class Ability
  include CanCan::Ability

  def initialize(user)
    if user.has_role? :superadmin
      can :manage, :all
    elsif user.has_role? :empadmin
      can :manage, Employee
    elsif user.has_role? :atttendance_admin
      role_for_attendance
    elsif user.has_role? :saleradmin
      role_for_saleradmin
    elsif user.has_role? :awardadmin
      role_for_awardadmin
    elsif user.has_role? :limitadmin
      role_for_limitadmin
    elsif user.has_role? :organsadmin
      roles_for_organs_offices
    elsif user.has_role? :workshopadmin
      roles_for_workshops
    else
      roles_for_groups
    end
  end


  # 考勤管理员权限
  def role_for_attendance
    can :read, Employee
  end


  # 财务管理员权限
  def role_for_saleradmin
  end


  #奖惩管理员权限
  def role_for_awardadmin
  end


  # 定额管理员权限
  def role_for_limitadmin
  end


  # 机关管理员/各科室管理员 权限
  def roles_for_organs_offices
  end


  # 车间管理员权限
  def roles_for_workshops
  end


  # 班组管理员权限
  def roles_for_groups
  end

end
