
class SequencesController < ApplicationController
  before_filter :set_sequence, :except => [:index, :new, :create]
  before_filter :find_or_create_sequence_run, :only => [:show]

  before_filter :enable_js_logger, :only => [:show]

  before_filter :setup_abilities, :only => [:new, :edit]

  # Adds remote_duplicate handler (POST remote_duplicate)
  include RemoteDuplicateSupport

  # Adds append_white_list_params support
  include ApplicationHelper

  # GET /sequences
  # GET /sequences.json
  def index
    @filter  = CollectionFilter.new(current_user, Sequence, params[:filter] || {})
    @sequences = @filter.collection.includes(:user,:lightweight_activities).paginate(:page => params['page'], :per_page => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sequences }
    end
  end

  # GET /sequences/1/print_blank
  def print_blank
    authorize! :read, @sequence
    render layout: "print_blank"
  end

  # GET /sequences/1
  # GET /sequences/1.json
  def show
    authorize! :read, @sequence

    uri = URI.parse(ENV['ACTIVITY_PLAYER_URL'])
    query = Rack::Utils.parse_query(uri.query)
    query["sequence"] = "#{api_v1_sequence_url(@sequence.id)}.json"
    uri.query = Rack::Utils.build_query(query)
    redirect_to uri.to_s
  end

  # GET /sequences/new
  # GET /sequences/new.json
  def new
    # Create a "blank" sequence in #create and head directly to #edit
    create
  end

  # GET /sequences/1/edit
  def edit
    authorize! :update, @sequence
    @activities = LightweightActivity.can_see(current_user)
    gon.publication_details = PublicationDetails.new(@sequence).to_json
  end

  # POST /sequences
  # POST /sequences.json
  def create
    @sequence = Sequence.new(params[:sequence])
    authorize! :create, @sequence
    @sequence.user = current_user

    respond_to do |format|
      if @sequence.save
        format.html { redirect_to edit_sequence_url(@sequence), notice: 'Sequence was successfully created.' }
        format.json { render json: @sequence, status: :created, location: @sequence }
      else
        format.html { render action: "new" }
        format.json { render json: @sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sequences/1
  # PUT /sequences/1.json
  def update
    authorize! :update, @sequence
    respond_to do |format|
      if @sequence.update_attributes(params[:sequence])
        format.html {
          flash[:notice] = "Sequence was successfully updated."
          redirect_to edit_sequence_path(@sequence)
        }
        format.json { head :no_content }
      else
        format.html {
          flash[:warning] = "There was a problem updating the sequence."
          redirect_to edit_sequence_path(@sequence)
        }
        format.json { render json: @sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_activity
    authorize! :update, @sequence
    activity = LightweightActivity.find(params[:activity_id])
    respond_to do |format|
      if @sequence.lightweight_activities << activity
        format.html { redirect_to edit_sequence_url(@sequence) }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_sequence_url(@sequence), notice: 'Activity was not added.' }
        format.json { render json: @sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  def remove_activity
    authorize! :update, @sequence
    activity = LightweightActivity.find(params[:activity_id])
    respond_to do |format|
      act_sequence = activity.for_sequence(@sequence)
      if act_sequence && act_sequence.remove_from_list
        act_sequence.delete
        format.html { redirect_to edit_sequence_url(@sequence), notice: 'Activity was successfully removed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_sequence_url(@sequence), notice: 'Activity was not removed.' }
        format.json { render json: @sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  def reorder_activities
    authorize! :update, @sequence
    params[:item_lightweight_activities_sequence].each do |a|
      # Format: item_lightweight_activities_sequence[]=1&item_lightweight_activities_sequence[]=3
      activity = @sequence.lightweight_activities_sequences.find(a)
      # If we move everything to the bottom in order, the first one should be at the top
      activity.move_to_bottom
    end
    # Respond with 200
    if request.xhr?
      respond_with_nothing
    else
      redirect_to edit_sequence_path(@sequence)
    end
  end

  # DELETE /sequences/1
  # DELETE /sequences/1.json
  def destroy
    @sequence.destroy
    authorize! :update, @sequence

    respond_to do |format|
      format.html { redirect_to sequences_url }
      format.json { head :no_content }
    end
  end

  def duplicate
    authorize! :duplicate, @sequence
    @new_sequence = @sequence.duplicate(current_user)
    redirect_to edit_sequence_path(@new_sequence)
  end

  def show_status
    @message = params[:message] || ''
    respond_to do |format|
      format.js { render :json => { :html => render_to_string('export')}, :content_type => 'text/json' }
      format.html
    end
  end

  def export
    authorize! :export, @sequence
    sequence_json = @sequence.export(request.host_with_port)
    send_data sequence_json, type: :json, disposition: "attachment", filename: "#{@sequence.name}_version_2.json"
  end

  def export_for_portal
    authorize! :export, @sequence
    self_url = "#{request.protocol}#{request.host_with_port}"
    sequence_json = @sequence.serialize_for_portal(self_url).to_json
    send_data sequence_json, type: :json, disposition: "attachment", filename: "#{@sequence.name}_version_2.json"
  end

  private
  def set_sequence
    @sequence = Sequence.find(params[:id])
  end

  def find_or_create_sequence_run
    if sequence_run_key = params['sequence_run_key']
      @sequence_run = SequenceRun.where(key: sequence_run_key).first!
      return @sequence_run
    end

    if params[:collaborators_data_url]
      # Special case when collaborators_data_url is provided (usually as a GET param).
      cc = CreateCollaboration.new(params[:collaborators_data_url], current_user, @sequence)
      @sequence_run = cc.call
    else
      portal = RemotePortal.new(params)
      @sequence_run = SequenceRun.lookup_or_create(@sequence, current_user, portal)
      # If sequence is ran with "portal" params, it means that user wants to run it individually.
      # Note that "portal" refers to individual student data endpoint, this name should be updated.
      if portal.valid?
        @sequence_run.disable_collaboration
      end
    end
  end

  def setup_abilities
    if params[:action] == "edit"
      @is_project_admin = current_user.project_admin_of?(@sequence.project) || (@sequence.user_id == current_user.id && current_user.is_project_admin?)
    else
      @is_project_admin = current_user.is_project_admin?
    end
  end
end
