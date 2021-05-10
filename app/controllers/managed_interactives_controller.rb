require_dependency "application_controller"

class ManagedInteractivesController < InteractiveController
  before_filter :set_interactive, :except => [:create, :new, :set_library_interactive]
  before_filter :can_manage, :only => :set_library_interactive

  def set_library_interactive
    @current_library_interactive_id = params[:current_library_interactive_id]
    @new_library_interactive_id = params[:new_library_interactive_id]
    @managed_interactives = ManagedInteractive.where(library_interactive_id: @current_library_interactive_id).all
    if @managed_interactives.length > 0
      @managed_interactives.each do |mi|
        mi.update_attribute(:library_interactive_id, @new_library_interactive_id)
      end
      @notice = 'All embeddables that used the library interactive have been updated to use the new version.'
    else
      @notice = 'No embeddables currently use the old version of that library interactive.'
    end
    respond_to do |format|
      format.html { redirect_to library_interactives_url, notice: @notice }
      format.json { head :no_content }
    end
  end

  private

  def set_interactive
    @interactive = ManagedInteractive.find(params[:id])
    set_page
  end

  def get_interactive_params
    @input_params = params[:managed_interactive]
  end

  def can_manage
    authorize! :manage, LibraryInteractive
  end
end

