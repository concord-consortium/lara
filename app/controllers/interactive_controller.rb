# Common code for the controllers for the different kinds of Interactive models
class InteractiveController < ApplicationController
  def edit
    respond_with_edit_form("allow-full-width")
  end

  def update
    set_page
    input_params = get_interactive_params
    # linked_interactives param follows ISetLinkedInteractives interface format. It isn't a regular attribute.
    # It requires special treatment and should be removed from params before .update is called.
    if input_params.has_key? :linked_interactives
      linked_linteractives = input_params.delete :linked_interactives
      if linked_linteractives.present?
        if !@interactive.page_item
          raise "Interactive needs to be added to a page"
        end
        @interactive.page_item.set_linked_interactives(JSON.parse linked_linteractives)
      end
    end
    @interactive.update! input_params
    respond_to do |format|
      update_activity_changed_by(@activity)
      format.html { redirect_to edit_activity_page_path(@activity, @page) }
      format.json { render json: @interactive.to_json }
    end
  end

  protected
  def set_page
    if @interactive
      @page = @interactive.page
      @activity = @interactive.activity
    end
  end
end
