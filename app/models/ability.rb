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
      # Authors can do the following, organized by model
      can :create, Glossary
      can :duplicate, Glossary
      can :export, Glossary
      can :import, Glossary
      can :manage, Glossary, :user_id => user.id
      can :read, Glossary

      can :create, InteractivePage
      can :manage, InteractivePage, :lightweight_activity => { :user_id => user.id }

      can :create, LightweightActivity
      can :duplicate, LightweightActivity, :is_locked => false, :publication_status => ['public', 'hidden']
      can :export, LightweightActivity, :is_locked => false, :publication_status => ['public', 'hidden']
      can :import, LightweightActivity
      can :manage, LightweightActivity, :user_id => user.id

      can :create, LinkedPageItem
      can :manage, LinkedPageItem, :primary => { :interactive_page => { :interactive_page => { :lightweight_activity => { :user_id => user.id } } } }

      can :create, PageItem
      can :manage, PageItem, :interactive_page => { :lightweight_activity => { :user_id => user.id } }

      can :create, Plugin
      can :manage, Plugin do |plugin|
        plugin.plugin_scope.user_id == user.id
      end

      can :create, Sequence
      can :duplicate, Sequence, :publication_status => ['public', 'hidden']
      can :export, Sequence
      can :import, Sequence
      can :manage, Sequence, :user_id => user.id
    end

    # Everyone (author and regular user) can update activities they own.
    can :update, LightweightActivity, :user_id => user.id
    # Everyone (author and regular user) can update pages in the activities they own.
    can :update, InteractivePage, :lightweight_activity => { :user_id => user.id }
    # Everyone (author and regular user) can update sequences they own.
    can :update, Sequence, :user_id => user.id
    # Everyone (author and regular user) can read public, hidden and archived sequences or activities.
    ['public', 'hidden', 'archive'].each do |allowed_status|
      can :read, Sequence, :publication_status => allowed_status
      can :read, LightweightActivity, :publication_status => allowed_status
      can :read, InteractivePage, :lightweight_activity => { :publication_status => allowed_status }
    end
    can :about, Project
    can :help, Project
    can :contact_us, Project

    can :access, Run do |run|
      admin_owner_or_anon_run(user, run)
    end

    can :access, SequenceRun do |sequence_run|
      admin_owner_or_anon_run(user, sequence_run)
    end

    can [:show, :update], InteractiveRunState do |interactive_run_state|
      # admins can do anything, unowned runs can be read/written by anyone, owned runs only by their owner or their collaborators
      run = interactive_run_state.run
      allowed = user.admin? || run.user.nil? || (user == run.user)
      if !allowed && run.collaboration_run
        allowed = run.collaboration_run.runs.where(activity_id: run.activity, user_id: user).length > 0
      end
      allowed
    end
  end

  private

  def admin_owner_or_anon_run(user, run)
    if user.admin?
      true
    elsif user.new_record?
      # We're currently anonymous
      run.user_id.nil?
    else
      run.user_id == user.id
    end
  end
end
