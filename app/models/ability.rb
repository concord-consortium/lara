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

    elsif user.is_project_admin?
      can :update, AuthoredContent do |authored_content|
        user.id == authored_content.user_id || user.can?(:update, authored_content.container)
      end

      can :create, Glossary
      can :duplicate, Glossary
      can :export, Glossary
      can :import, Glossary
      can :manage, Glossary do |glossary|
        user.id == glossary.user_id || user.project_admin_of?(glossary.project)
      end
      can :read, Glossary

      can :create, InteractivePage
      can :manage, InteractivePage do |page|
        user.id == page.lightweight_activity.user_id || user.project_admin_of?(page.lightweight_activity.project)
      end

      can :create, LightweightActivity
      can :duplicate, LightweightActivity do |activity|
        user.id == activity.user_id || user.project_admin_of?(activity.project) || (!activity.is_locked && ['public', 'hidden'].include?(activity.publication_status))
      end
      can :export, LightweightActivity do |activity|
        user.id == activity.user_id || user.project_admin_of?(activity.project) || (!activity.is_locked && ['public', 'hidden'].include?(activity.publication_status))
      end
      can :import, LightweightActivity
      can :manage, LightweightActivity do |activity|
        user.id == activity.user_id || user.project_admin_of?(activity.project)
      end

      can :create, LinkedPageItem
      can :manage, LinkedPageItem do |linked_page_item|
        activity = linked_page_item.primary.interactive_page.lightweight_activity
        user.id == activity.user_id || user.project_admin_of?(activity.project)
      end

      can :create, PageItem
      can :manage, PageItem do |page_item|
        activity = page_item.interactive_page.lightweight_activity
        user.id == activity.user_id || user.project_admin_of?(activity.project)
      end

      can :create, Plugin
      can :manage, Plugin do |plugin|
        user.id == plugin.plugin_scope.user_id || user.project_admin_of?(plugin.plugin_scope.project)
      end

      can :manage, Project do |project|
        user.project_admin_of?(project)
      end

      can :create, Rubric
      can :duplicate, Rubric
      can :export, Rubric
      can :import, Rubric
      can :manage, Rubric do |rubric|
        user.id == rubric.user_id || user.project_admin_of?(rubric.project)
      end
      can :read, Rubric

      can :create, Sequence
      can :duplicate, Sequence do |sequence|
        user.id == sequence.user_id || user.project_admin_of?(sequence.project) || ['public', 'hidden'].include?(sequence.publication_status)
      end
      can :export, Sequence do |sequence|
        user.id == sequence.user_id || user.project_admin_of?(sequence.project) || ['public', 'hidden'].include?(sequence.publication_status)
      end
      can :import, Sequence
      can :manage, Sequence do |sequence|
        user.id == sequence.user_id || user.project_admin_of?(sequence.project)
      end

    elsif user.author?
      # Authors can do the following, organized by model
      can :update, AuthoredContent, :user_id => user.id

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

      can :create, Rubric
      can :duplicate, Rubric
      can :export, Rubric
      can :import, Rubric
      can :manage, Rubric, :user_id => user.id
      can :read, Rubric

      can :create, Sequence
      can :duplicate, Sequence, :publication_status => ['public', 'hidden']
      can :export, Sequence
      can :import, Sequence
      can :manage, Sequence, :user_id => user.id
    end

    # anyone can read authored content
    can :read, AuthoredContent

    # Everyone (author and regular user) can update glossaries they own.
    can :update, Glossary do |glossary|
      user.id == glossary.user_id || user.project_admin_of?(glossary.project)
    end
    # Everyone (author and regular user) can update rubrics they own.
    can :update, Rubric do |rubric|
      user.id == rubric.user_id || user.project_admin_of?(rubric.project)
    end
    # Everyone (author and regular user) can update activities they own.
    can :update, LightweightActivity do |activity|
      user.id == activity.user_id || user.project_admin_of?(activity.project)
    end
    # Everyone (author and regular user) can update pages in the activities they own.
    can :update, InteractivePage do |page|
      user.id == page.lightweight_activity.user_id || user.project_admin_of?(page.lightweight_activity)
    end
    # Everyone (author and regular user) can update sequences they own.
    can :update, Sequence do |sequence|
      user.id == sequence.user_id || user.project_admin_of?(sequence.project)
    end
    # Everyone (author and regular user) can read public, hidden and archived sequences or activities.
    ['public', 'hidden', 'archive'].each do |allowed_status|
      can :read, Sequence do |sequence|
        sequence.publication_status == allowed_status || user.project_admin_of?(sequence.project)
      end
      can :read, LightweightActivity do |activity|
        activity.publication_status == allowed_status || user.project_admin_of?(activity.project)
      end
      can :read, InteractivePage do |page|
        page.lightweight_activity.publication_status == allowed_status || user.project_admin_of?(page.lightweight_activity)
      end
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
