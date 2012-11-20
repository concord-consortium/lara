class Embeddable::MultipleChoicesController < ApplicationController
  def edit
    @embeddable = Embeddable::MultipleChoice.find(params[:id])
    respond_to do |format|
      format.js { render :json => { :html => render_to_string('edit')}, :content_type => 'text/json' }
      format.html
    end
  end

  def update
    cancel = params[:commit] == "Cancel"
    @multiple_choice = Embeddable::MultipleChoice.find(params[:id])
    if request.xhr?
      respond_to do |format|
        if cancel || @multiple_choice.update_attributes(params[:embeddable_multiple_choice])
          @multiple_choice.reload
          format.xml { render :edit, :layout => false }
        else
          format.xml { render :xml => @multiple_choice.errors, :status => :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        if @multiple_choice.update_attributes(params[:embeddable_multiple_choice])
          flash[:notice] = 'Multiple choice was successfully updated.'
          format.html { redirect_to(:back) }
          format.xml  { head :ok }
        else
          format.html { render :edit }
          format.xml  { render :xml => @multiple_choice.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def add_choice
    @multiple_choice = Embeddable::MultipleChoice.find(params[:id])
    @multiple_choice.add_choice("New choice")
    if request.xhr?
      respond_to do |format|
        @multiple_choice.reload
        format.xml { render 'edit.html.haml', :layout => false }
        format.json
      end
    else
      respond_to do |format|
        flash[:notice] = 'New choice was added.'
        format.html { redirect_to(:back) }
        format.xml  { head :ok }
        format.json
      end
    end
  end

  def remove_choice
    @multiple_choice = Embeddable::MultipleChoice.find(params[:id], :include => :choices)
    @choice = @multiple_choice.choices.find(params[:choice_id])
    @choice.destroy
    if request.xhr?
      respond_to do |format|
        @multiple_choice.reload
        format.xml { render :edit, :layout => false }
        format.json
      end
    else
      respond_to do |format|
        flash[:notice] = 'New choice was added.'
        format.html { redirect_to(:back) }
        format.xml  { head :ok }
        format.json
      end
    end
  end
end