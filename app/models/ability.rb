class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :index, :show, :filter, :age_statistical_analysis, :education_statistical_analysis, :working_years_statistical_analysis, :worktype_statistical_analysis, :rali_years_statistical_analysis,  :statistical_analysis_data, :organization_structure, :compsite_statistical_analysis, to: :leader_read
    if user.has_role? :superadmin
      can :manage, :all
    elsif user.has_role? :leaderadmin
      can :leader_read, Employee
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
    can :read, Employee
  end


  #奖惩管理员权限
  def role_for_awardadmin
    can :read, Employee
  end


  # 定额管理员权限
  def role_for_limitadmin
    can :read, Employee
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