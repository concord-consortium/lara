# Common code for the controllers for the different kinds of Interactive models
class InteractiveController < ApplicationController

  def new
    create
  end

  def edit
    respond_with_edit_form
  end

  def destroy
    @interactive.interactive_item.delete
    typestring = @interactive.class.to_s.match(/(.+)Interactive/)[1]
    if @interactive.delete
      @activity = @page.lightweight_activity
      update_activity_changed_by
      redirect_to edit_activity_page_path(@activity, @page), :flash => { :notice => "Your #{typestring} interactive was deleted." }
    else
      redirect_to edit_activity_page_path(@page.lightweight_activity, @page), :flash => { :warning => "There was a problem deleting the #{typestring} interactive." }
    end
  end

  protected
  def set_page
    @page = InteractivePage.find(params[:page_id]) if params[:page_id]
  end
end
