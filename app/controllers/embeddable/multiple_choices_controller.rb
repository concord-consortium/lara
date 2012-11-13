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
          format.xml { render :partial => 'show', :locals => { :multiple_choice => @multiple_choice } }
          format.json
        else
          format.xml { render :xml => @multiple_choice.errors, :status => :unprocessable_entity }
          format.json
        end
      end
    else
      respond_to do |format|
        if @multiple_choice.update_attributes(params[:embeddable_multiple_choice])
          flash[:notice] = 'Multiplechoice was successfully updated.'
          format.html { redirect_to(:back) }
          format.xml  { head :ok }
          format.json
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @multiple_choice.errors, :status => :unprocessable_entity }
          format.json
        end
      end
    end
  end
end