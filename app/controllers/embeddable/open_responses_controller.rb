class Embeddable::OpenResponsesController < ApplicationController
  # PUT /Embeddable/open_responses/1
  # PUT /Embeddable/open_responses/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @open_response = Embeddable::OpenResponse.find(params[:id])
    if request.xhr?
      respond_to do |format|
        if cancel || @open_response.update_attributes(params[:embeddable_open_response])
          format.xml { render :partial => 'show', :locals => { :open_response => @open_response } }
          format.json { respond_with_bip @open_response }
        else
          format.xml { render :xml => @open_response.errors, :status => :unprocessable_entity }
          format.json { respond_with_bip @open_response }
        end
      end
    else
      respond_to do |format|
        if @open_response.update_attributes(params[:embeddable_open_response])
          flash[:notice] = 'Embeddable::OpenResponse.was successfully updated.'
          format.html { redirect_to(@open_response) }
          format.xml  { head :ok }
          format.json { respond_with_bip @open_response }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @open_response.errors, :status => :unprocessable_entity }
          format.json { respond_with_bip @open_response }
        end
      end
    end
  end
end
