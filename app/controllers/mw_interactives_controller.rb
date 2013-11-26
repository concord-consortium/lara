require_dependency "application_controller"

class MwInteractivesController < InteractiveController
  before_filter :set_interactive, :except => [:new, :create]

  def update
    if (@interactive.update_attributes(params[:mw_interactive]))
      # respond success
      flash[:notice] = 'Your MW Interactive was updated'
    else
      flash[:warning] = "There was a problem updating your MW Interactive"
    end
    respond_to do |format|
      if @page
        @activity = @page.lightweight_activity
        update_activity_changed_by
        format.html { redirect_to edit_activity_page_path(@activity, @page) }
      else
        format.html { redirect_to edit_mw_interactive_path(@interactive) }
      end
    end
  end

  private
  def set_interactive
    @interactive = MwInteractive.find(params[:id])
    set_page
  end

  def create_interactive
    @interactive = MwInteractive.create!()
    @params = { edit_mw_int: @interactive.id }
  end
end

