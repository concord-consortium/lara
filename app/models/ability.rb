class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here.
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    user ||= User.new # guest user (not logged in)
    if user.admin?
      can :manage, :all
      # TODO: Set up author permissions
      # TODO: Set up authenticated user permissions
      # TODO: Set up anonymous permissions
    end
  end
end
