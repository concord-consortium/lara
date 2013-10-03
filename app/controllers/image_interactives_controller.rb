class ImageInteractivesController < InteractiveController
  before_filter :set_interactive, :except => [:new, :create]

  def create
    if (params[:page_id])
      @page = InteractivePage.find(params[:page_id])
      @activity = @page.lightweight_activity
      @interactive = ImageInteractive.create!()
      InteractiveItem.create!(:interactive_page => @page, :interactive => @interactive)
      flash[:notice] = "Your new Image has been created."
      update_activity_changed_by
      redirect_to edit_activity_page_path(@activity, @page, :edit_img_int => @interactive.id)
    else
      @interactive = ImageInteractive.create!()
      flash[:notice] = "Your new Image has been created."
      redirect_to edit_image_interactive_path(@interactive)
    end
  end

  def update
    if (@interactive.update_attributes(params[:image_interactive]))
      # respond success
      flash[:notice] = 'Your image was updated'
    else
      flash[:warning] = "There was a problem updating your image"
    end
    respond_to do |format|
      if @page
        @activity = @page.lightweight_activity
        update_activity_changed_by
        format.html { redirect_to edit_activity_page_path(@activity, @page) }
      else
        format.html { redirect_to edit_image_interactive_path(@interactive) }
      end
    end
  end

  private
  def set_interactive
    @interactive = ImageInteractive.find(params[:id])
    set_page
  end
end
