# Common code for the controllers for the different kinds of Interactive models
class InteractiveController < ApplicationController

  def new
    create
  end

  def edit
    respond_with_edit_form
  end

  def create
    set_page
    create_interactive
    flash[:notice] = "Your new #{@interactive.class.string_name} has been created."
    if (@page)
      InteractiveItem.create!(:interactive_page => @page, :interactive => @interactive)
      update_activity_changed_by
      redirect_to edit_activity_page_path(@activity, @page, @params)
    else
      redirect_to :back # edit_polymorphic_path(@interactive)
    end
  end

  def update
    set_page
    if (@interactive.update_attributes(get_interactive_params))
      # respond success
      flash[:notice] = "Your #{@interactive.class.string_name} was updated."
    else
      flash[:warning] = "There was a problem updating your #{@interactive.class.string_name}."
    end
    respond_to do |format|
      if @page
        update_activity_changed_by(@activity)
        format.html { redirect_to edit_activity_page_path(@activity, @page) }
      else
        format.html { redirect_to :back }
      end
    end
  end


  def toggle_visibility
    new_val = !@interactive.is_hidden
    @interactive.update_attributes!(is_hidden: new_val)
    if request.xhr?
      render json: {is_hidden: new_val}
    else
      redirect_to :back
    end
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
    if params[:page_id]
      @page = InteractivePage.find(params[:page_id], :include => :lightweight_activity)
      @activity = @page.lightweight_activity
    end
  end
end
