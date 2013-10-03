class VideoInteractivesController < InteractiveController
  before_filter :set_interactive, :except => [:new, :create]

  def create
    @interactive = VideoInteractive.create!()
    @interactive.sources << VideoSource.new() # If we don't have one, weird stuff happens
    flash[:notice] = "Your new video has been created."
    if (params[:page_id])
      @page = InteractivePage.find(params[:page_id])
      @activity = @page.lightweight_activity
      InteractiveItem.create!(:interactive_page => @page, :interactive => @interactive)
      update_activity_changed_by(@activity)
      redirect_to edit_activity_page_path(@activity, @page, :edit_vid_int => @interactive.id)
    else
      redirect_to edit_video_interactive_path(@interactive)
    end
  end

  def edit
    if @interactive.sources.length < 1
      @interactive.sources << VideoSource.new() # If we don't have one, weird stuff happens
    end
    respond_with_edit_form
  end

  def update
    if (@interactive.update_attributes(params[:video_interactive]))
      # respond success
      flash[:notice] = 'Your video was updated'
    else
      flash[:warning] = "There was a problem updating your video"
    end
    respond_to do |format|
      if @page
        update_activity_changed_by(@page.lightweight_activity) unless @page.lightweight_activity.nil?
        format.html { redirect_to edit_activity_page_path(@activity, @page) }
      else
        format.html { redirect_to edit_video_interactive_path(@interactive) }
      end
    end
  end

  def add_source
    @source = VideoSource.new(:video_interactive => @interactive)
    @interactive.reload
    update_activity_changed_by(@interactive.activity) unless @interactive.activity.nil?
    respond_to do |format|
      if request.xhr?
        format.js { render :json => { :html => render_to_string('edit')}, :content_type => 'text/json' }
      else
        flash[:notice] = 'New source was added.'
        format.html { redirect_to(:back) }
        format.xml  { head :ok }
        format.json
      end
    end
  end

  def remove_source
    @interactive.video_sources.find(params[:source_id]).destroy
    @interactive.reload
    update_activity_changed_by(@interactive.activity) unless @interactive.activity.nil?
    respond_to do |format|
      if request.xhr?
        format.js { render :json => { :html => render_to_string('edit')}, :content_type => 'text/json' }
      else
        flash[:notice] = 'Source removed.'
        format.html { redirect_to(:back) }
        format.xml  { head :ok }
        format.json
      end
    end
  end

  private
  def set_interactive
    @interactive = VideoInteractive.find(params[:id])
    set_page
  end
end
