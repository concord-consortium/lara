require_dependency "application_controller"

class LightweightActivitiesController < ApplicationController

  # TODO: We use "run key", "session key" and "response key" for the same bit of data here. Refactor to fix.
  before_filter :set_activity, :except => [:index, :new, :create]
  before_filter :set_run_key,  :only   => [:summary, :show, :preview, :resubmit_answers, :single_page]
  before_filter :set_sequence, :only   => [:summary, :show, :single_page]

  before_filter :enable_js_logger, :only => [:summary, :show, :preview, :single_page]

  layout :set_layout

  def index
    @filter  = CollectionFilter.new(current_user, LightweightActivity, params[:filter] || {})
    @community_activities = @filter.collection.includes(:user,:changed_by,:portal_publications).community
    @official_activities  = @filter.collection.includes(:user,:changed_by,:portal_publications).official
    @community_activities = @community_activities.paginate(:page => params['community_page_number'], :per_page => 10)
    @official_activities  = @official_activities.paginate(:page => params['official_page_number'], :per_page => 10)
  end

  # These are the runtime (student-facing) actions, show and summary

  def show # show index
    if params[:class_info_url]
      @run.class_info_url = params[:class_info_url]
      @run.save!
    end

    authorize! :read, @activity
    if params[:print]
      redirect_to activity_single_page_with_response_path(@activity, @run.key, request.query_parameters) and return
    end

    if params[:response_key]
      redirect_to sequence_activity_path(@run.sequence, @activity, request.query_parameters) and return if @run.sequence
      redirect_to activity_path(@activity, request.query_parameters) and return
    end

    @run.increment_run_count!

    if @activity.layout == LightweightActivity::LAYOUT_SINGLE_PAGE
      redirect_to activity_single_page_with_response_path(@activity, @run.key) and return
    end
    if @run.last_page && !@run.last_page.is_hidden && !params[:show_index]
      # TODO: If the Page isn't in this activity... Then we need to log that as an error,
      # and do the best we can to get back to the right page...
      if @activity != @run.last_page.lightweight_activity
        Rails.logger.error("Page has wrong activity or vice versa")
        Rails.logger.error("Page: #{@run.last_page.id}  wrong activity: #{@activity.id} right activity: #{@run.last_page.lightweight_activity.id}")
        @activity = @run.last_page.lightweight_activity
      end
      redirect_to page_with_response_path(@activity.id, @run.last_page.id, @run.key) and return
    end

    setup_show
  end

  def preview
    # This is "show" but it clears answers first
    authorize! :update, @activity # Authors only
    @run.clear_answers
    if @activity.layout == LightweightActivity::LAYOUT_SINGLE_PAGE
      setup_single_page_show
      @labbook_is_under_interactive = true
      render :single_page, :locals => {:print => params[:print]}
    else
      setup_show
      render :show
    end
  end

  def single_page
    authorize! :read, @activity
    if !params[:response_key]
      redirect_to activity_single_page_with_response_path(@activity, @session_key) and return
    end

    setup_single_page_show

    # the authorization needs to be after the setup method so that at least the @theme instance variable
    # is set, so the theme of the unauthorized_run page remains the same.
    begin
      authorize! :access, @run
    rescue
      user_id_mismatch()
      render 'runs/unauthorized_run'
      return
    end
    @labbook_is_under_interactive = true
  end

  def print_blank
    authorize! :read, @activity
    @run = Run.new()
    setup_show
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

  # The remaining actions are all authoring actions.

  def new
    @activity = LightweightActivity.new()
    authorize! :create, @activity
  end

  def create
    @activity = LightweightActivity.new(params[:lightweight_activity])
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

    @editor_mode = @activity.editor_mode
    if params[:mode] && current_user.admin?
      @editor_mode = case params[:mode]
                       when "itsi" then LightweightActivity::ITSI_EDITOR_MODE
                       else LightweightActivity::STANDARD_EDITOR_MODE
                     end
    end

    # Data assigned to `gon` variable will be available for JavaScript code in `window.gon` object.
    # this is used in both the itsi editor and in the standard editor to show the published activity
    gon.ITSIEditor = ITSIAuthoring::Editor.new(@activity).to_json

    if @editor_mode == LightweightActivity::ITSI_EDITOR_MODE
      render :itsi_edit
    else
      render :edit
    end
  end

  def update
    authorize! :update, @activity
    update_activity_changed_by
    respond_to do |format|
      if @activity.update_attributes(params[:lightweight_activity])
        format.json { render json: @activity }
        format.html {
          flash[:notice] = "Activity #{@activity.name} was updated."
          redirect_to edit_activity_path(@activity)
        }
      else
        format.json { render json: @activity.errors, :status => :unprocessable_entity }
        format.html {
          # I'd like to use the activity name here, but what if that's what's the invalid update?
          flash[:warning] = "There was a problem updating your activity."
          redirect_to edit_activity_path(@activity)
        }
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

  # FIXME this should really be something other than a GET since it has side effects
  def duplicate
    authorize! :duplicate, @activity
    @new_activity = @activity.duplicate(current_user)

    unless @new_activity.valid?
      flash[:warning] = "<p>The duplicated activity had validation issues:</p> #{@new_activity.errors} <p>Work carefully with the new activity.</p>"
    end

    if @new_activity.save(:validations => false) # In case the old activity was invalid
      # check if we should publish this new activity somewhere
      json_response = nil
      if params['add_to_portal']
        req_url = "#{request.protocol}#{request.host_with_port}"
        # this might take a little time so it might be better do this in the background
        response = @new_activity.portal_publish(current_user,params['add_to_portal'],req_url)
        begin
          json_response = JSON.parse(response.body)
        rescue
        end
      end
      if params['redirect_on_success'] && json_response && json_response.has_key?("activity_id")
        redirect_to params['redirect_on_success'].sub!(':activity_id', json_response['activity_id'].to_s)
      else
        redirect_to edit_activity_path(@new_activity)
      end
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
    answers.last.send_to_portal
    flash[:notice] = "#{answers.length} #{'answer'.pluralize(answers.length)} requeued for submission."
    redirect_to :back
  end

  private
  def set_activity
    if params[:activity_id]
      id = params[:activity_id]
    else
      id = params[:id]
    end

    if params[:sequence_id]
      sequence = Sequence.find(params[:sequence_id])
      @activity = sequence.activities.find(id)
    else
      @activity = LightweightActivity.find(id)
    end
  end

  def set_layout
    case params[:action]
    when 'show'
      return 'runtime'
    when 'preview'
      return 'runtime'
    when 'print_blank'
      return 'print_blank'
    when 'single_page'
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

  def setup_single_page_show
    setup_show
    setup_global_interactive_state_data
  end
end
