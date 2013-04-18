require_dependency "application_controller"

class InteractivePagesController < ApplicationController
  before_filter :set_page, :except => [:new, :create]
  before_filter :set_session_key, :only => [:show]

  def show
    authorize! :read, @page

    if !params[:response_key]
      redirect_to page_with_response_path(@activity, @page, @session_key) and return
    else
      @all_pages = @activity.pages
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
    had_interactive = @page.interactives.length
    update_activity_changed_by
    respond_to do |format|
      if @page.update_attributes(params[:interactive_page])
        format.html do
          if request.xhr?
            # *** respond with the new value ***
            render :text => params[:interactive_page].values.first
          else
            @page.reload
            param = {}
            if @page.interactives.length > had_interactive
              param = { :edit_int => @page.interactives.last.id }
            end
            flash[:notice] = "Page #{@page.name} was updated."
            redirect_to edit_activity_page_path(@activity, @page, param)
          end
        end
      else
        format.html do
          if request.xhr?
            # *** repond with the old value ***
            render :text => @page[params[:interactive_page].keys.first]
          else
            flash[warning] = "There was a problem updating Page #{@page.name}."
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
