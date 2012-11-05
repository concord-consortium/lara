class Embeddable::MultipleChoicesController < ApplicationController
  def update
    cancel = params[:commit] == "Cancel"
    @multiple_choice = Embeddable::MultipleChoice.find(params[:id])
    if request.xhr?
      respond_to do |format|
        if cancel || @multiple_choice.update_attributes(params[:embeddable_multiple_choice])
          @multiple_choice.reload
          format.xml { render :partial => 'show', :locals => { :multiple_choice => @multiple_choice } }
          format.json { respond_with_bip @multiple_choice }
        else
          format.xml { render :xml => @multiple_choice.errors, :status => :unprocessable_entity }
          format.json { respond_with_bip @multiple_choice }
        end
      end
    else
      respond_to do |format|
        if @multiple_choice.update_attributes(params[:embeddable_multiple_choice])
          flash[:notice] = 'Multiplechoice was successfully updated.'
          format.html { redirect_to(@multiple_choice) }
          format.xml  { head :ok }
          format.json { respond_with_bip @multiple_choice }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @multiple_choice.errors, :status => :unprocessable_entity }
          format.json { respond_with_bip @multiple_choice }
        end
      end
    end
  end
end