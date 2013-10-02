require_dependency "application_controller"
require 'concord_portal_publishing'

class LightweightActivitiesController < ApplicationController
  include ConcordPortalPublishing

  # TODO: We use "run key", "session key" and "response key" for the same bit of data here. Refactor to fix.
  before_filter :set_activity, :except => [:index, :new, :create]
  before_filter :set_run_key,  :only   => [:summary, :show]
  before_filter :set_sequence, :only   => [:summary, :show]
  layout :set_layout

  def index
    @filter  = CollectionFilter.new(current_user, LightweightActivity, params[:filter] || {})
    @community_activities = @filter.collection.community
    @official_activities  = @filter.collection.official
  end

  def show
    authorize! :read, @activity
    current_theme
    current_project
    if !params[:response_key]
      redirect_to activity_with_response_path(@activity, @session_key) and return
    end
    @run.increment_run_count!

    @pages = @activity.pages
  end

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
    if @activity.update_attributes(params[:lightweight_activity])
      if request.xhr?
        render :text => params[:lightweight_activity].values.first
      else
        flash[:notice] = "Activity #{@activity.name} was updated."
        redirect_to edit_activity_path(@activity)
      end
    else
      # I'd like to use the activity name here, but what if that's what's the invalid update?
      if request.xhr?
        render :text => "There was a problem updating your activity. Please reload the page and try again."
      else
        flash[:warning] = "There was a problem updating your activity."
        redirect_to edit_activity_path(@activity)
      end
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
    authorize! :duplicate, LightweightActivity
    @new_activity = @activity.duplicate
    # Set ownership - doing this in the instance methods isn't practical

    @new_activity.set_user!(current_user)

    if @new_activity.save
      redirect_to edit_activity_path(@new_activity)
    else
      flash[:warning] = "Copy failed"
      redirect_to activities.path
    end
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
      respond_to do |format|
        format.js { render :nothing => true }
        format.html { render :nothing => true }
      end
    else
      redirect_to edit_activity_path(@activity)
    end
  end

  def summary
    authorize! :read, @activity
    current_theme
    current_project
    if !params[:response_key]
      redirect_to summary_with_response_path(@activity, @session_key) and return
    end
    @answers = @activity.answers(@run)
  end

  def publish
    authorize! :publish, @activity
    @activity.publish!
    success = portal_publish(@activity)
    if success
      flash[:notice] = "Successfully published activity!"
    else
      # There should already be an error message from portal_publish in the flash hash
      flash[:alert] << "<br />Failed to publish activity! Check that you're logged in to the portal, and have permissions to author."
    end
    redirect_to activities_path
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
    when 'summary'
      return 'summary'
    else
      return 'application'
    end
  end
end
