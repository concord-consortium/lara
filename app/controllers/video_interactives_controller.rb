class VideoInteractivesController < ApplicationController
  before_filter :set_interactive, :except => [:new, :create]

  def new
    create
  end

  def create
    if (params[:page_id])
      @page = InteractivePage.find(params[:page_id])
      @activity = @page.lightweight_activity
      @interactive = VideoInteractive.create!()
      InteractiveItem.create!(:interactive_page => @page, :interactive => @interactive)
      flash[:notice] = "Your new video has been created."
      update_activity_changed_by
      redirect_to edit_activity_page_path(@activity, @page, :edit_vid_int => @interactive.id)
    else
      @interactive = VideoInteractive.create!()
      flash[:notice] = "Your new video has been created."
      redirect_to edit_video_interactive_path(@interactive)
    end
  end

  def edit
    respond_to do |format|
      format.js { render :json => { :html => render_to_string('edit')}, :content_type => 'text/json' }
      format.html
    end
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
        @activity = @page.lightweight_activity
        update_activity_changed_by
        format.html { redirect_to edit_activity_page_path(@activity, @page) }
      else
        format.html { redirect_to edit_video_interactive_path(@interactive) }
      end
    end
  end

  def destroy
    @interactive.interactive_item.delete
    if @interactive.delete
      @activity = @page.lightweight_activity
      update_activity_changed_by
      redirect_to edit_activity_page_path(@activity, @page), :flash => { :notice => 'Your video was deleted.' }
    else
      redirect_to edit_activity_page_path(@page.lightweight_activity, @page), :flash => { :warning => 'There was a problem deleting the video.' }
    end
  end

  def add_source
    @source = VideoSource.new(:video_interactive => @interactive)
    @interactive.reload
    @activity = @interactive.activity
    update_activity_changed_by unless @activity.nil?
    if request.xhr?
      respond_to do |format|
        format.js { render :json => { :html => render_to_string('edit')}, :content_type => 'text/json' }
      end
    else
      respond_to do |format|
        flash[:notice] = 'New choice was added.'
        format.html { redirect_to(:back) }
        format.xml  { head :ok }
        format.json
      end
    end
  end

  def remove_source
    @source = @interactive.video_sources.find(params[:source_id])
    @source.destroy
    @interactive.reload
    @activity = @interactive.activity
    update_activity_changed_by unless @activity.nil?
    if request.xhr?
      respond_to do |format|
        format.js { render :json => { :html => render_to_string('edit')}, :content_type => 'text/json' }
      end
    else
      respond_to do |format|
        flash[:notice] = 'New source was added.'
        format.html { redirect_to(:back) }
        format.xml  { head :ok }
        format.json
      end
    end
  end

  private
  def set_interactive
    @interactive = VideoInteractive.find(params[:id])
    if params[:page_id]
      @page = InteractivePage.find(params[:page_id])
    end
  end
end
