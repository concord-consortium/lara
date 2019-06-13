require_dependency "application_controller"

class InteractivePagesController < ApplicationController
  before_filter :set_page, :except => [:new, :create]
  before_filter :only => [:show, :preview] { set_run_key(portal_launchable: false) }
  before_filter :set_sequence, :only => [:show]
  before_filter :check_if_hidden, :only => [:show, :preview]

  before_filter :enable_js_logger, :only => [:show, :preview]

  layout 'runtime', :only => [:show, :preview]

  include PageHelper

  def show
    authorize! :read, @page
    if !params[:run_key]
      redirect_to_page_with_run_path(@sequence, @activity.id, @page.id, @run_key, request.query_parameters) and return
    end

    setup_theme_and_project
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
    @page = InteractivePage.new(:lightweight_activity => @activity)
    authorize! :create, @page
    @page.save!
    update_activity_changed_by
    flash[:notice] = "A new page was added to #{@activity.name}"
    redirect_to edit_activity_page_path(@activity, @page)
  end

  def edit
    authorize! :update, @page
    @all_pages = @activity.pages
    gon.publication_details = PublicationDetails.new(@activity).to_json
  end

  def update
    authorize! :update, @page
    update_activity_changed_by
    respond_to do |format|
      if request.xhr?
        if @page.update_attributes(params[:interactive_page])
          # *** respond with the new value ***
          format.html { render :text => params[:interactive_page].values.first }
        else
          # *** respond with the old value ***
          format.html { render :text => @page[params[:interactive_page].keys.first] }
        end
        format.json { render :json => @page.to_json }
      else
        format.html do
          if @page.update_attributes(params[:interactive_page])
            @page.reload # In case it's the name we updated
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

  def add_tracked
    authorize! :update, @page
    update_activity_changed_by
    qt = QuestionTracker.find(params[:question_tracker])
    question = qt.new_question
    @page.add_embeddable(question)
    edit_embeddable_redirect(question)
  end

  def add_embeddable
    authorize! :update, @page
    update_activity_changed_by
    e = Embeddable.create_for_string(params[:embeddable_type])
    if (params[:embeddable_type] == Embeddable::EmbeddablePlugin.to_s)
      e.approved_script_id = params[:approved_script_id] if !params[:approved_script_id].empty?
      e.component_label = params[:component_label] if !params[:component_label].empty?
      e.save!
    end
    @page.add_embeddable(e, nil, params[:section])
    # The call below supposed to open edit dialog, but it doesn't seem to work anymore.
    edit_embeddable_redirect(e)
  end

  def remove_embeddable
    authorize! :update, @page
    update_activity_changed_by
    PageItem.find_by_interactive_page_id_and_embeddable_id(params[:id], params[:embeddable_id]).destroy
    # We aren't removing the embeddable itself. But we would remove the tracked_question of the embeddable.
    redirect_to edit_activity_page_path(@activity, @page)
  end

  def toggle_hideshow_embeddable
    authorize! :update, @page
    update_activity_changed_by
    PageItem.find_by_interactive_page_id_and_embeddable_id(params[:id], params[:embeddable_id]).toggle_hideshow_embeddable
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
      pi = PageItem.find(:first, :conditions => { :embeddable_id => embeddable_id, :embeddable_type => embeddable_type })
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

  def edit_embeddable_redirect(embeddable)
    case embeddable
      when Embeddable::MultipleChoice
        unless embeddable.choices.length > 0
          embeddable.create_default_choices
        end
        param = { :edit_embed_mc => embeddable.id }
      when Embeddable::OpenResponse
        param = { :edit_embed_or => embeddable.id }
      when Embeddable::ImageQuestion
        param = { :edit_embed_iq => embeddable.id }
      when Embeddable::Labbook
        param = { :edit_embed_lb => embeddable.id }
      when Embeddable::Xhtml
        param = { :edit_embed_xhtml => embeddable.id }
      when MwInteractive
        param = { :edit_mw_int => embeddable.id }
      when ImageInteractive
        param = { :edit_img_int => embeddable.id }
      when VideoInteractive
        param = { :edit_vid_int => embeddable.id }
    end
    # Add parameter to open new embeddable modal
    redirect_to edit_activity_page_path(@activity, @page, param)
  end

  def check_if_hidden
    raise ActiveRecord::RecordNotFound if @page.is_hidden
  end

  def set_page
    if params[:activity_id]
      @activity = LightweightActivity.find(params[:activity_id], :include => :pages)
      @page = @activity.pages.find(params[:id])
      # TODO: Exception handling if the ID'd Page doesn't belong to the ID'd Activity
    else
      # I don't like this method much.
      @page = InteractivePage.find(params[:id], :include => :lightweight_activity)
      @activity = @page.lightweight_activity
    end
  end

  def setup_theme_and_project
    current_theme
    current_project
  end

  def setup_show
    setup_theme_and_project
    setup_global_interactive_state_data
    @all_pages = @activity.pages
    @run.set_last_page(@page)
  end
end
