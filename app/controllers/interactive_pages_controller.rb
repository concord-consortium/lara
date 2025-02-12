class InteractivePagesController < ApplicationController
  before_action :set_page, except: [:new, :create]
  before_action :set_run_key_to_false, only: [:show, :preview]
  before_action :set_sequence, only: [:show]
  before_action :check_if_hidden, only: [:show, :preview]

  before_action :enable_js_logger, only: [:show, :preview]

  layout 'runtime', only: [:show, :preview]

  include PageHelper

  def show
    authorize! :read, @page
    if !params[:run_key]
      redirect_to_page_with_run_path(@sequence, @activity.id, @page.id, @run_key, request.query_parameters) and return
    end

    setup_project
    raise_error_if_not_authorized_run(@run)

    setup_show
    respond_to do |format|
      format.html
      format.xml
    end
  end

  def preview
    # This is "show" but it clears answers first
    authorize! :update, @page # Authors only
    @preview_mode = true
    if @activity.layout == LightweightActivity::LAYOUT_SINGLE_PAGE
      redirect_to preview_activity_path(@activity) and return
    end
    @run.clear_answers
    setup_show
    render :show
  end

  def new
    # There's really nothing to do here; we can go through #create and skip on ahead to #edit.
    create
  end

  def create
    @activity = LightweightActivity.find(params[:activity_id])
    @page = InteractivePage.new(lightweight_activity: @activity)
    authorize! :create, @page
    @page.save!
    last_idx = @activity.pages.length - 1
    prev_last_idx = @activity.pages.length - 2
    if @activity.pages[prev_last_idx].is_completion
      @activity.pages[prev_last_idx].position = last_idx
      @activity.pages[prev_last_idx].move_lower
    end
    update_activity_changed_by
    flash[:notice] = "A new page was added to #{@activity.name}"
    redirect_to edit_activity_page_path(@activity, @page)
  end

  def edit
    authorize! :update, @page
    @all_pages = @activity.pages
    gon.publication_details = PublicationDetails.new(@activity).to_json
  end

  def update_params
    params.require(:interactive_page).permit(
      :lightweight_activity, :name, :position, :layout, :sidebar, :show_header,
      :show_sidebar, :show_interactive, :show_info_assessment, :toggle_info_assessment,
      :embeddable_display_mode, :sidebar_title, :is_hidden, :additional_sections, :is_completion
    )
  end

  def update
    authorize! :update, @page
    respond_to do |format|
      if request.xhr?
        if @page.update_attributes(update_params)
          # *** respond with the new value ***
          update_activity_changed_by
          format.html { render plain: params[:interactive_page].values.first }
        else
          # *** respond with the old value ***
          format.html { render plain: @page[params[:interactive_page].keys.first] }
        end
        format.json { render json: @page.to_json }
      else
        format.html do
          if @page.update_attributes(update_params)
            @page.reload # In case it's the name we updated
            update_activity_changed_by
            flash[:notice] = "Page #{@page.name} was updated."
          else
            flash[:warning] = "There was a problem updating Page #{@page.name}."
          end
          redirect_to edit_activity_page_path(@activity, @page) and return
        end
      end
    end
  end

  def destroy
    authorize! :destroy, @page
    update_activity_changed_by
    if @page.remove_from_list
      @page.delete
      flash[:notice] = "Page #{@page.name} was deleted."
      redirect_to edit_activity_path(@activity)
    else
      flash[:warning] = "There was a problem deleting page #{@page.name}."
      redirect_to edit_activity_path(@activity)
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

  def add_section
    authorize! :update, @page
    @page.add_section
    update_activity_changed_by
    redirect_to edit_activity_page_path(@activity, @page)
  end

  def remove_section
    authorize! :update, @page
    update_activity_changed_by
    @section.destroy
    redirect_to edit_activity_page_path(@activity, @page)
  end

  def remove_page_item
    authorize! :update, @page
    update_activity_changed_by
    @page_item.destroy
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
      pi = PageItem.where(embeddable_id: embeddable_id, embeddable_type: embeddable_type).first
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

  def set_run_key_to_false
    set_run_key(portal_launchable: false)
  end

  def edit_embeddable_redirect(embeddable)
    case embeddable
      when Embeddable::MultipleChoice
        unless embeddable.choices.length > 0
          embeddable.create_default_choices
        end
        param = { edit_mc: embeddable.id }
      when Embeddable::OpenResponse
        param = { edit_or: embeddable.id }
      when Embeddable::ImageQuestion
        param = { edit_iq: embeddable.id }
      when Embeddable::Labbook
        param = { edit_lb: embeddable.id }
      when Embeddable::Xhtml
        param = { edit_xhtml: embeddable.id }
      when Embeddable::ExternalScript
        param = { edit_external_script: embeddable.id }
      when Embeddable::EmbeddablePlugin
        param = { edit_embeddable_plugin: embeddable.id }
      when MwInteractive
        param = { edit_mw_int: embeddable.id }
      when ManagedInteractive
        param = { edit_managed_int: embeddable.id }
      when ImageInteractive
        param = { edit_image: embeddable.id }
      when VideoInteractive
        param = { edit_video: embeddable.id }
    end
    # Add parameter to open new embeddable modal
    redirect_to edit_activity_page_path(@activity, @page, param)
  end

  def check_if_hidden
    raise ActiveRecord::RecordNotFound if @page.is_hidden
  end

  def set_page
    if params[:activity_id]
      @activity = LightweightActivity.includes(:pages).find(params[:activity_id])
      @page = @activity.pages.find(params[:id])
      # TODO: Exception handling if the ID'd Page doesn't belong to the ID'd Activity
    elsif params[:page_item_id]
      @page_item = PageItem.find_by_id(params[:page_item_id])
      @page = @page_item.interactive_page
      @activity = @page.lightweight_activity
    elsif params[:section_id]
      @section = Section.find_by_id(params[:section_id])
      @page = @section.interactive_page
      @activity = @page.lightweight_activity
    else
      # I don't like this method much.
      @page = InteractivePage.includes(:lightweight_activity).find(params[:id])
      @activity = @page.lightweight_activity
    end
  end

  def setup_project
    current_project
  end

  def setup_show
    setup_project
    setup_global_interactive_state_data
    @all_pages = @activity.pages
    @run.set_last_page(@page)
  end
end
