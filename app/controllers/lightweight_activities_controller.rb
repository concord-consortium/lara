require_dependency "application_controller"

class LightweightActivitiesController < ApplicationController

  before_filter :set_activity, :except => [:index, :new, :create]
  before_filter :only => [:summary, :show, :preview, :resubmit_answers, :single_page] {
    portal_launchable = (action_name == 'show' && params[:sequence_id].blank?)
    set_run_key(portal_launchable: portal_launchable)
  }
  before_filter :set_sequence, :only   => [:summary, :show, :single_page, :preview]

  before_filter :enable_js_logger, :only => [:summary, :show, :preview, :single_page]

  layout :set_layout

  # Adds remote_duplicate handler (POST remote_duplicate)
  include RemoteDuplicateSupport

  include PageHelper
  include LightweightActivityHelper

  def index
    @filter  = CollectionFilter.new(current_user, LightweightActivity, params[:filter] || {})
    @community_activities = @filter.collection.includes(:user,:changed_by,:portal_publications).community
    @official_activities  = @filter.collection.includes(:user,:changed_by,:portal_publications).official
    @community_activities = @community_activities.paginate(:page => params['community_page_number'], :per_page => 10)
    @official_activities  = @official_activities.paginate(:page => params['official_page_number'], :per_page => 10)
  end

  # These are the runtime (student-facing) actions, show and summary
  def show # show index
    authorize! :read, @activity

    uri = URI.parse(ENV['ACTIVITY_PLAYER_URL'])
    query = Rack::Utils.parse_query(uri.query)
    if request.url.include? "/sequences/"
      query["sequence"] = "#{api_v1_sequence_url(params[:sequence_id])}.json"
      query["sequenceActivity"] = "activity_#{params[:id]}"
    else
      query["activity"] = "#{api_v1_activity_url(params[:id])}.json"
    end
    query["runKey"] = params[:run_key] if params[:run_key]
    uri.query = Rack::Utils.build_query(query)
    redirect_to uri.to_s
  end

  def preview
    # This is "show" but it clears answers first and sets the preview mode flag
    authorize! :update, @activity # Authors only
    @run.clear_answers
    @preview_mode = true
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
    if !params[:run_key]
      redirect_to runnable_single_page_activity_path(@activity) and return
    end

    setup_single_page_show

    # the authorization needs to be after the setup method so that at least the @theme instance variable
    # is set, so the theme of the unauthorized_run page remains the same.
    raise_error_if_not_authorized_run(@run)
    @labbook_is_under_interactive = true

    @run.increment_run_count!
  end

  def print_blank
    authorize! :read, @activity
    @run = Run.new()
    @run.activity = @activity
    setup_show
  end

  def summary
    redirect_to runnable_summary_path(@activity)
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
    lightweight_activity_json = @activity.export(request.host_with_port).to_json
    send_data lightweight_activity_json, type: :json, disposition: "attachment", filename: "#{@activity.name}_version_2.json"
  end

  def export_for_portal
    authorize! :export, @activity
    self_url = "#{request.protocol}#{request.host_with_port}"
    publication_json = @activity.serialize_for_portal(self_url).to_json
    send_data publication_json, type: :json, disposition: "attachment", filename: "#{@activity.name}_version_2.json"
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
    if !params[:run_key]
      flash[:notice] = "It's not possible to resubmit answers without run key."
      redirect_to activities_path and return
    end
    answers = @activity.answers(@run)
    answers.each { |a| a.mark_dirty }
    # Kick off a resubmit
    answers.last.send_to_portal
    flash[:notice] = "#{answers.length} #{'answer'.pluralize(answers.length)} requeued for submission."
    redirect_to :back
  end

  def add_plugin
    authorize! :update, @activity
    @activity.plugins.create({
      approved_script_id: params[:approved_script_id],
      component_label: params[:component_label]
    })
    if request.xhr?
      respond_with_nothing
    else
      redirect_to edit_activity_path(@activity)
    end
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
