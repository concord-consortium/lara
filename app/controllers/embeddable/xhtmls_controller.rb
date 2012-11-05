class Embeddable::XhtmlsController < ApplicationController
  # PUT /Embeddable/xhtmls/1
  # PUT /Embeddable/xhtmls/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @xhtml = Embeddable::Xhtml.find(params[:id])
    if request.xhr?
      respond_to do |format|
        if cancel || @xhtml.update_attributes(params[:embeddable_xhtml])
          format.xml { render :partial => 'show', :locals => { :xhtml => @xhtml } }
          format.json { respond_with_bip @xhtml }
        else
          format.xml { render :xml => @xhtml.errors, :status => :unprocessable_entity }
          format.json { respond_with_bip @xhtml }
        end
      end
    else
      respond_to do |format|
        if @xhtml.update_attributes(params[:embeddable_xhtml])
          flash[:notice] = 'Embeddable::Xhtml.was successfully updated.'
          format.html { redirect_to(@xhtml) }
          format.xml  { head :ok }
          format.json { respond_with_bip @xhtml }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @xhtml.errors, :status => :unprocessable_entity }
          format.json { respond_with_bip @xhtml }
        end
      end
    end
  end
end
