class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here.
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    user ||= User.new # guest user (not logged in)
    if user.admin?
      # Admins can do everything
      can :manage, :all
    elsif user.author?
      # Authors can create new items and manage those they created
      can :create, Sequence
      can :create, LightweightActivity
      can :create, InteractivePage
      can :manage, Sequence, :user_id => user.id
      can :manage, LightweightActivity, :user_id => user.id
      can :manage, InteractivePage, :lightweight_activity => { :user_id => user.id }
      # and duplicate unlocked activities and sequences
      can :duplicate, LightweightActivity, :is_locked => false, :publication_status => 'public'
      can :duplicate, Sequence, :publication_status => 'public'
    end
    # Everyone (author and regular user) can read public sequences activities
    can :read, Sequence, :publication_status => 'public'
    can :read, LightweightActivity, :publication_status => 'public'
    can :read, InteractivePage, :lightweight_activity => { :publication_status => 'public' }
    # Private sequences and activities can be read, too, but they're not in the lists
    can :read, Sequence, :publication_status => 'private'
    can :read, LightweightActivity, :publication_status => 'private'
    can :read, InteractivePage, :lightweight_activity => { :publication_status => 'private' }
  end
end
