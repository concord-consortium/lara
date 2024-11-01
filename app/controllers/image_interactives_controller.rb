class ImageInteractivesController < InteractiveController
  before_action :set_interactive, :except => [:new, :create]

  private
  def set_interactive
    @interactive = ImageInteractive.find(params[:id])
    set_page
  end

  def create_interactive
    @interactive = ImageInteractive.create!()
    @params = { edit_img_int: @interactive.id }
  end

  def get_interactive_params
    @input_params = params[:image_interactive]
  end
end
