class Ability
  include CanCan::Ability

  def initialize(user)
    if user && !user.blocked?
      can :manage, :all
    end
  end
end
