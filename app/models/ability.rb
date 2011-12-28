class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      # TODO: refactor permissions.
      can :manage, :all
    end
  end
end
