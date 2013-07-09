require_dependency "application_controller"

class InteractivePagesController < ApplicationController
  before_filter :set_page, :except => [:new, :create]
  before_filter :set_run_key, :only => [:show]

  layout 'runtime', :only => [:show]

  def show
    authorize! :read, @page
    current_theme
    current_project

    if !params[:response_key]
      redirect_to page_with_response_path(@activity.id, @page.id, @session_key) and return
    else
      @all_pages = @activity.pages
      finder = Embeddable::AnswerFinder.new(@run)
      @run.update_attribute(:page, @page)
      @modules = @page.embeddables.map { |e| finder.find_answer(e) }
    end

    respond_to do |format|
      format.html
      format.xml
    end
  end

  def new
    # There's really nothing to do here; we can go through #create and skip on ahead to #edit.
    create
  end

  def create
    @activity = LightweightActivity.find(params[:activity_id])
    @page = InteractivePage.create!(:lightweight_activity => @activity)
    authorize! :create, @page
    update_activity_changed_by
    flash[:notice] = "A new page was added to #{@activity.name}"
    redirect_to edit_activity_page_path(@activity, @page)
  end

  def edit
    authorize! :update, @page
    @all_pages = @activity.pages
  end

  def update
    authorize! :update, @page
    update_activity_changed_by
    respond_to do |format|
      if @page.update_attributes(params[:interactive_page])
        format.html do
          if request.xhr?
            # *** respond with the new value ***
            render :text => params[:interactive_page].values.first
          else
            @page.reload
            flash[:notice] = "Page #{@page.name} was updated."
            redirect_to edit_activity_page_path(@activity, @page)
          end
        end
      else
        format.html do
          if request.xhr?
            # *** repond with the old value ***
            render :text => @page[params[:interactive_page].keys.first]
          else
            flash[:warning] = "There was a problem updating Page #{@page.name}."
            redirect_to edit_activity_page_path(@activity, @page)
          end
        end
      end
    end
  end

  def destroy
    authorize! :destroy, @page
    update_activity_changed_by
    if @page.delete
      flash[:notice] = "Page #{@page.name} was deleted."
      redirect_to edit_activity_path(@activity)
    else
      flash[:warning] = "There was a problem deleting page #{@page.name}."
      redirect_to edit_activity_path(@activity)
    end
  end

  def add_interactive
    authorize! :update, @page
    update_activity_changed_by
    i = params[:interactive_type].constantize.create!
    @page.add_interactive(i)
    if i.instance_of?(ImageInteractive)
      param = { :edit_img_int => i.id }
    elsif i.instance_of?(MwInteractive)
      param = { :edit_mw_int => i.id }
    elsif i.instance_of?(VideoInteractive)
      param = { :edit_vid_int => i.id }
    end
    redirect_to edit_activity_page_path(@activity, @page, param)
  end

  def add_embeddable
    authorize! :update, @page
    update_activity_changed_by
    e = params[:embeddable_type].constantize.create!
    @page.add_embeddable(e)
    if e.instance_of?(Embeddable::MultipleChoice)
      e.create_default_choices
      param = { :edit_embed_mc => e.id }
    elsif e.instance_of?(Embeddable::OpenResponse)
      param = { :edit_embed_or => e.id }
    elsif e.instance_of?(Embeddable::Xhtml)
      param = { :edit_embed_xhtml => e.id }
    end
    # Add parameter to open new embeddable modal
    redirect_to edit_activity_page_path(@activity, @page, param)
  end

  def remove_embeddable
    authorize! :update, @page
    update_activity_changed_by
    PageItem.find_by_interactive_page_id_and_embeddable_id(params[:id], params[:embeddable_id]).destroy
    redirect_to edit_activity_page_path(@activity, @page)
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
      respond_to do |format|
        format.js { render :nothing => true }
        format.html { render :nothing => true }
      end
    else
      redirect_to edit_activity_page_path(@activity, @page)
    end
  end

  private
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
end
