class Ability
  include CanCan::Ability

  def initialize(user)
    if user && !user.is_banned? && !user.is_removed?
      can :manage, :all
    end
  end
end
