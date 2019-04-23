
class SequencesController < ApplicationController
  before_filter :set_sequence, :except => [:index, :new, :create]
  before_filter :find_or_create_sequence_run, :only => [:show]

  before_filter :enable_js_logger, :only => [:show]

  # Adds remote_duplicate handler (POST remote_duplicate)
  include RemoteDuplicateSupport

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
    current_theme
    current_project
    respond_to do |format|
      format.html do
        if @sequence_run && @sequence_run.has_been_run
          unless params[:show_index]
            activity = @sequence_run.most_recent_activity
            redirect_to sequence_activity_with_run_path(@sequence, activity, @sequence_run.run_for_activity(activity))
            return
          end
        end
        # show.html.erb  ⬅ default template is shown otherwise
        render layout: "sequence_run"
      end
      format.json { render json: @sequence }
    end
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
        format.html { redirect_to @sequence, notice: 'Sequence was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
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
    sequence_json = @sequence.export
    send_data sequence_json, type: :json, disposition: "attachment", filename: "#{@sequence.name}_version_1.json"
  end

  private
  def set_sequence
    @sequence = Sequence.find(params[:id])
  end

  def find_or_create_sequence_run
    if sequence_run_id = params['sequence_run']
      @sequence_run = SequenceRun.find(sequence_run_id)
      return @sequence_run if @sequence_run
    end

    return nil unless current_user
    # Special case when collaborators_data_url is provided (usually as a GET param).
    if params[:collaborators_data_url]
      cc = CreateCollaboration.new(params[:collaborators_data_url], current_user, @sequence)
      @sequence_run = cc.call
    else
      portal = RemotePortal.new(params)
      @sequence_run = SequenceRun.lookup_or_create(@sequence, current_user, portal)
      # If sequence is ran with "portal" params, it means that user wants to run it individually.
      # Note that "portal" refers to individual student data endpoint, this name should be updated.
      @sequence_run.disable_collaboration if portal.valid?
    end
  end

end
