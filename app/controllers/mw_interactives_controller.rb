require_dependency "application_controller"

class MwInteractivesController < InteractiveController
  before_filter :set_interactive, :except => [:new, :create]

  private
  def set_interactive
    @interactive = MwInteractive.find(params[:id])
    set_page
  end

  def create_interactive
    @interactive = MwInteractive.create!()
    @params = { edit_mw_int: @interactive.id }
  end

  def get_interactive_params
    @input_params = params[:mw_interactive]
  end
end

