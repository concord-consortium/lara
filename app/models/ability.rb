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
    elsif user.author?
      can :create, LightweightActivity
      can :create, InteractivePage
      can :manage, LightweightActivity, :user_id => user.id
      can :manage, InteractivePage, :lightweight_activity => { :user_id => user.id }
    else
      can :read, LightweightActivity, :publication_status => 'public'
      can :read, InteractivePage, :lightweight_activity => { :publication_status => 'public' }
    end
  end
end
