require 'concord_portal_publishing'

class SequencesController < ApplicationController
  include ConcordPortalPublishing
  layout 'sequence_run', :only => [:show]
  before_filter :set_sequence, :except => [:index, :new, :create]
  before_filter :find_or_create_sequence_run, :only => [:show]

  # GET /sequences
  # GET /sequences.json
  def index
    @sequences = Sequence.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sequences }
    end
  end

  # GET /sequences/1
  # GET /sequences/1.json
  def show
    authorize! :read, @sequence
    current_theme
    current_project
    respond_to do |format|
      format.html # show.html.erb
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
  end

  # POST /sequences
  # POST /sequences.json
  def create
    @sequence = Sequence.new(params[:sequence], :user_id => current_user.id)
    authorize! :create, @sequence
    if @sequence.user != current_user
      @sequence.user = current_user
    end

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
        # binding.pry
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
      if @sequence.lightweight_activities.delete(activity)
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
      respond_to do |format|
        format.js { render :nothing => true }
        format.html { render :nothing => true }
      end
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

  def publish
    authorize! :publish, @sequence
    success = portal_publish(@sequence)
    if success
      flash[:notice] = "Successfully published sequence!"
    else
      # There should already be an error message from portal_publish in the flash hash
      flash[:alert] << "<br />Failed to publish sequence! Check that you're logged in to the portal, and have permissions to author."
    end
    redirect_to sequences_path
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

    portal = RemotePortal.new(params)
    if session.delete(:did_reauthenticate)
      @sequence_run = SequenceRun.lookup_or_create(@sequence, current_user, portal)
    else
      update_portal_session
    end
    # This creates a new sequnce_run if it doesn't exist.
  end

end
