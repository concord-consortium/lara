require_dependency "application_controller"

class ManagedInteractivesController < InteractiveController
  before_filter :set_interactive, :except => [:new, :create]

  private
  def set_interactive
    @interactive = ManagedInteractive.find(params[:id])
    set_page
  end

  def create_interactive
    @interactive = ManagedInteractive.create!()
    @params = { edit_managed_int: @interactive.id }
  end

  def get_interactive_params
    @input_params = params[:managed_interactive]
  end
end

