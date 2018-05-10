class Ability
  include CanCan::Ability

  def initialize(user)
    if user.has_role? :superadmin
      can :manage, :all
    else
      can :read, Employee
    end
  end

end
