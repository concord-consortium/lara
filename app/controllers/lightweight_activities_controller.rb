require_dependency "application_controller"

class LightweightActivitiesController < ApplicationController

  # TODO: We use "run key", "session key" and "response key" for the same bit of data here. Refactor to fix.
  before_filter :set_activity, :except => [:index, :new, :create]
  before_filter :set_run_key,  :only   => [:summary, :show, :preview, :resubmit_answers]
  before_filter :set_sequence, :only   => [:summary, :show]
  layout :set_layout

  def index
    @filter  = CollectionFilter.new(current_user, LightweightActivity, params[:filter] || {})
    @community_activities = @filter.collection.includes(:user,:changed_by,:portal_publications).community
    @official_activities  = @filter.collection.includes(:user,:changed_by,:portal_publications).official
    @community_activities = @community_activities.paginate(:page => params['community_page_number'], :per_page => 10)
    @official_activities  = @official_activities.paginate(:page => params['official_page_number'], :per_page => 10)
  end

  # These are the runtime (student-facing) actions, show and summary

  def show
    authorize! :read, @activity
    if params[:response_key]
      redirect_to sequence_activity_path(@run.sequence, @activity, request.query_parameters) and return if @run.sequence
      redirect_to activity_path(@activity, request.query_parameters) and return
    end
    @run.increment_run_count!
    setup_show
    unless params[:show_index]
      if @run && @run.last_page && @activity
        # TODO: If the Page isn't in this activity... Then we need to log that as an error, 
        # and do the best we can to get back to the right page...
        if @activity != @run.last_page.lightweight_activity
          Rails.logger.error("Page has wrong activity or vice versa")
          Rails.logger.error("Page: #{@run.last_page.id}  wrong activity: #{@activity.id} right activity: #{@run.last_page.lightweight_activity.id}")
          @activity = @run.last_page.lightweight_activity
        end
        redirect_to page_with_response_path(@activity.id, @run.last_page.id, @run.key)
        return
      end
    end
  end

  def preview
    # This is "show" but it clears answers first
    authorize! :update, @activity # Authors only
    @run.clear_answers
    setup_show
    render :show
  end

  def summary
    authorize! :read, @activity
    current_theme
    current_project
    if !params[:response_key]
      redirect_to summary_with_response_path(@activity, @session_key) and return
    end
    @answers = @activity.answers(@run).select { |a| a.show_in_report }
  end

  # The remaining actions are all authoring actions.

  def new
    @activity = LightweightActivity.new()
    authorize! :create, @activity
  end

  def create
    @activity = LightweightActivity.create(params[:lightweight_activity])
    authorize! :create, @activity
    @activity.user = current_user
    @activity.changed_by = current_user
    if @activity.save
      flash[:notice] = "Lightweight Activity #{@activity.name} was created."
      redirect_to edit_activity_path(@activity)
    else
      flash[:warning] = "There was a problem creating the new Lightweight Activity."
      render :new
    end
  end

  def edit
    authorize! :update, @activity
  end

  def update
    authorize! :update, @activity
    update_activity_changed_by
    if request.xhr?
      if @activity.update_attributes(params[:lightweight_activity])
        render :text => params[:lightweight_activity].values.first
      else
        render :text => "There was a problem updating your activity. Please reload the page and try again."
      end
    else
      if @activity.update_attributes(params[:lightweight_activity])
        flash[:notice] = "Activity #{@activity.name} was updated."
      else
        # I'd like to use the activity name here, but what if that's what's the invalid update?
        flash[:warning] = "There was a problem updating your activity."
      end
      redirect_to edit_activity_path(@activity)
    end
  end

  def destroy
    authorize! :destroy, @activity
    if @activity.delete
      flash[:notice] = "Activity #{@activity.name} was deleted."
      redirect_to activities_path
    else
      flash[:warning] = "There was a problem deleting activity #{@activity.name}."
      redirect_to edit_activity_path(@activity)
    end
  end

  def duplicate
    authorize! :duplicate, @activity
    @new_activity = @activity.duplicate(current_user)

    unless @new_activity.valid?
      flash[:warning] = "<p>The duplicated activity had validation issues:</p> #{@new_activity.errors} <p>Work carefully with the new activity.</p>"
    end

    if @new_activity.save(:validations => false) # In case the old activity was invalid
      redirect_to edit_activity_path(@new_activity)
    else
      flash[:warning] = "Copy failed"
      redirect_to activities_path
    end
  end
  
  def show_status
    @message = params[:message] || ''
    respond_to do |format|
      format.js { render :json => { :html => render_to_string('export')}, :content_type => 'text/json' }
      format.html
    end
  end
  
  def export
    authorize! :export, @activity
    lightweight_activity_json = @activity.export.to_json
    send_data lightweight_activity_json, type: :json, disposition: "attachment", filename: "#{@activity.name}_version_1.json"
  end
  
  def move_up
    authorize! :update, @activity
    @page = @activity.pages.find(params[:id])
    @page.move_higher
    update_activity_changed_by
    redirect_to :back
  end

  def move_down
    authorize! :update, @activity
    @page = @activity.pages.find(params[:id])
    @page.move_lower
    update_activity_changed_by
    redirect_to :back
  end

  def reorder_pages
    authorize! :update, @activity
    params[:item_interactive_page].each do |p|
      # Format: item_interactive_page[]=1&item_interactive_page[]=3&item_interactive_page[]=11&item_interactive_page[]=12&item_interactive_page[]=13&item_interactive_page[]=21&item_interactive_page[]=20&item_interactive_page[]=2
      page = @activity.pages.find(p)
      # If we move everything to the bottom in order, the first one should be at the top
      page.move_to_bottom
    end
    update_activity_changed_by
    # Respond with 200
    if request.xhr?
      respond_with_nothing
    else
      redirect_to edit_activity_path(@activity)
    end
  end

  def resubmit_answers
    authorize! :manage, :all
    if !params[:response_key]
      # If we don't know the run, we can't do this.
      redirect_to summary_with_response_path(@activity, @session_key) and return
    end
    answers = @activity.answers(@run)
    answers.each { |a| a.mark_dirty }
    # Kick off a resubmit
    answers.last.send_to_portal('Bearer %s' % current_user.authentication_token)
    flash[:notice] = "#{answers.length} #{'answer'.pluralize(answers.length)} requeued for submission."
    redirect_to :back
  end


  private
  def set_activity
    if params[:activity_id]
      @activity = LightweightActivity.find(params[:activity_id])
    else
      @activity = LightweightActivity.find(params[:id])
    end
  end

  def set_layout
    case params[:action]
    when 'show'
      return 'runtime'
    when 'preview'
      return 'runtime'
    when 'summary'
      return 'summary'
    else
      return 'application'
    end
  end

  def setup_show
    current_theme
    current_project
    @pages = @activity.pages
  end
end
