require_dependency "application_controller"

class MwInteractivesController < ApplicationController
  before_filter :set_interactive, :except => [:new, :create]

  def new
    create
  end

  def create
    if (params[:page_id])
      @page = InteractivePage.find(params[:page_id])
      @activity = @page.lightweight_activity
      @interactive = MwInteractive.create!()
      InteractiveItem.create!(:interactive_page => @page, :interactive => @interactive)
      flash[:notice] = "Your new MW Interactive has been created."
      update_activity_changed_by
      redirect_to edit_activity_page_path(@activity, @page, :edit_int => @interactive.id)
    else
      @interactive = MwInteractive.create!()
      flash[:notice] = "Your new MW Interactive has been created."
      redirect_to edit_mw_interactive_path(@interactive)
    end
  end

  def edit
    respond_to do |format|
      format.js { render :json => { :html => render_to_string('edit')}, :content_type => 'text/json' }
      format.html
    end
  end

  def update
    if (@interactive.update_attributes(params[:mw_interactive]))
      # respond success
      flash[:notice] = 'Your MW Interactive was updated'
    else
      flash[:warning] = "There was a problem updating your MW Interactive"
    end
    respond_to do |format|
      if @page
        @activity = @page.lightweight_activity
        update_activity_changed_by
        format.html { redirect_to edit_activity_page_path(@activity, @page) }
      else
        format.html { redirect_to edit_mw_interactive_path(@interactive) }
      end
    end
  end

  def destroy
    @interactive.interactive_item.delete
    if @interactive.delete
      @activity = @page.lightweight_activity
      update_activity_changed_by
      redirect_to edit_activity_page_path(@activity, @page), :flash => { :notice => 'Your interactive was deleted.' }
    else
      redirect_to edit_activity_page_path(@page.lightweight_activity, @page), :flash => { :warning => 'There was a problem deleting the interactive.' }
    end
  end

  private
  def set_interactive
    @interactive = MwInteractive.find(params[:id])
    if params[:page_id]
      @page = InteractivePage.find(params[:page_id])
    end
  end
end

