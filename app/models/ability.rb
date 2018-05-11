class Ability
  include CanCan::Ability

  def initialize(user)
    if user.has_role? :superadmin
      can :manage, :all
    elsif user.has_role? :empadmin
      can :manage, Employee
    end
  end

end
