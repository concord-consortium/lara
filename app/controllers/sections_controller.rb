require_dependency "application_controller"

class SectionsController < ApplicationController
  before_action :set_page

  def update_params
    params.require(:section).permit(:title, :position, :show, :layout, :interactive_page, :interactive_page_id, :can_collapse_small, :name)
  end

  def update
    authorize! :update, @page
    puts params[:section]
    respond_to do |format|
      if request.xhr?
        if @section.update_attributes(update_params)
          # *** respond with the new value ***
          update_activity_changed_by
          format.html { render plain: params[:section].values.first }
        else
          # *** respond with the old value ***
          format.html { render plain: @section[params[:section].keys.first] }
        end
        format.json { render json: @section.to_json }
      else
        format.html do
          if @section.update_attributes(update_params)
            @section.reload # In case it's the name we updated
            update_activity_changed_by
            flash[:notice] = "Page #{@section.name} was updated."
          else
            flash[:warning] = "There was a problem updating Page #{@section.name}."
          end
          redirect_to edit_activity_page_path(@activity, @page) and return
        end
      end
    end
  end


  def add_embeddable
    authorize! :update, @page
    update_activity_changed_by
    e = Embeddable.create_for_string(params[:embeddable_type])
    if (params[:embeddable_type] == Embeddable::EmbeddablePlugin.to_s)
      e.approved_script_id = params[:approved_script_id] if !params[:approved_script_id].blank?
      e.component_label = params[:component_label] if !params[:component_label].blank?
      e.embeddable_select_value = params[:embeddable_select_value] if !params[:embeddable_select_value].blank?
      e.save!
    end
    if params[:section] == 'header_block'
      e.is_half_width = false
      e.save
    end
    @page.add_embeddable(e, nil, params[:section])
    # The call below supposed to open edit dialog, but it doesn't seem to work anymore.
    edit_embeddable_redirect(e)
  end

  def remove_page_item
    authorize! :update, @page
    update_activity_changed_by
    @page_item.destroy
    # We aren't removing the embeddable itself. But we would remove the tracked_question of the embeddable.
    redirect_to edit_activity_page_path(@activity, @page)
  end

  def toggle_hideshow_page_item
    authorize! :update, @page
    update_activity_changed_by
    @page_item.toggle_hideshow_embeddable
    if request.xhr?
      respond_with_nothing
    else
      redirect_to edit_activity_page_path(@activity, @page)
    end
  end

  def reorder_embeddables
    authorize! :update, @page
    update_activity_changed_by
    params[:embeddable].each do |e|
      # Format: embeddable[]=17.Embeddable::OpenResponse&embeddable[]=20.Embeddable::Xhtml&embeddable[]=19.Embeddable::OpenResponse&embeddable[]=19.Embeddable::Xhtml&embeddable[]=17.Embeddable::MultipleChoice&embeddable[]=16.Embeddable::OpenResponse
      embeddable_id, embeddable_type = e.split('.')
      pi = PageItem.find(conditions: { embeddable_id: embeddable_id, embeddable_type: embeddable_type }).first
      # If we move everything to the bottom in order, the first one should be at the top
      pi.move_to_bottom
    end
    # Respond with 200
    if request.xhr?
      respond_with_nothing
    else
      redirect_to edit_activity_page_path(@activity, @page)
    end
  end

  private

  def edit_redirect()
    # Add parameter to open new embeddable modal
    redirect_to edit_activity_page_path(@activity, @page, param)
  end

  def set_page
    if params[:page_id]
      @page = InteractivePage.includes(:lightweight_activity).find(params[:id])
      @activity = @page.lightweight_activity
    else
      @section = Section.find_by_id(params[:id])
      @page = @section.interactive_page
      @activity = @page.lightweight_activity
    end
  end

end
