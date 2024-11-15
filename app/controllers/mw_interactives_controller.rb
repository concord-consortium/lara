require_dependency "application_controller"

class MwInteractivesController < InteractiveController
  before_action :set_interactive, except: [:new, :create]

  private
  def set_interactive
    @interactive = MwInteractive.find(params[:id])
    set_page
  end

  def create_interactive
    @interactive = MwInteractive.create!()
    @params = { edit_mw_int: @interactive.id }
  end

  def mw_interactive_params
    params.require(:mw_interactive).permit(
      :id, :_destroy,
      :name, :url, :native_width, :native_height,
      :enable_learner_state, :has_report_url, :click_to_play,
      :click_to_play_prompt, :image_url, :is_hidden, :linked_interactive_id, :linked_interactive_type,
      :full_window, :model_library_url, :authored_state, :no_snapshots,
      :show_delete_data_button, :show_in_featured_question_report, :is_half_width,
      :aspect_ratio_method, :linked_interactive_item_id, :report_item_url,
      :linked_interactives, :hide_question_number
    )
  end

  def get_interactive_params
    @input_params = mw_interactive_params
  end
end

