require_dependency "application_controller"

class ManagedInteractivesController < InteractiveController
  before_action :set_interactive, :except => [:new, :create]

  private

  def set_interactive
    @interactive = ManagedInteractive.find(params[:id])
    set_page
  end

  def update_params
    params.require(:managed_interactive).permit(
      :library_interactive_id,
      :name,
      :url_fragment,
      :is_half_width,
      :show_in_featured_question_report,
      :authored_state,
      :is_hidden,
      :linked_interactive_id, :linked_interactive_type,
      :inherit_aspect_ratio_method, :custom_aspect_ratio_method,
      :inherit_native_width, :custom_native_width,
      :inherit_native_height, :custom_native_height,
      :inherit_click_to_play, :custom_click_to_play,
      :inherit_full_window, :custom_full_window,
      :inherit_click_to_play_prompt, :custom_click_to_play_prompt,
      :inherit_image_url, :custom_image_url,
      :linked_interactive_item_id,
      :legacy_ref_id, :legacy_ref_type,
      :linked_interactives,
      :hide_question_number
    )
  end

  def get_interactive_params
    @input_params = update_params
  end
end

