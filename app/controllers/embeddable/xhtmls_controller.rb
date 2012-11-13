class Embeddable::XhtmlsController < ApplicationController
  def edit
    @embeddable = Embeddable::Xhtml.find(params[:id])
    respond_to do |format|
      format.js { render :json => { :html => render_to_string('edit')}, :content_type => 'text/json' }
      format.html
    end
  end

  # PUT /Embeddable/xhtmls/1
  # PUT /Embeddable/xhtmls/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @xhtml = Embeddable::Xhtml.find(params[:id])
    if request.xhr?
      respond_to do |format|
        if cancel || @xhtml.update_attributes(params[:embeddable_xhtml])
          format.xml { render :partial => 'show', :locals => { :xhtml => @xhtml } }
          format.json
        else
          format.xml { render :xml => @xhtml.errors, :status => :unprocessable_entity }
          format.json
        end
      end
    else
      respond_to do |format|
        if @xhtml.update_attributes(params[:embeddable_xhtml])
          flash[:notice] = 'Embeddable::Xhtml.was successfully updated.'
          format.html { redirect_to(@xhtml) }
          format.xml  { head :ok }
          format.json
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @xhtml.errors, :status => :unprocessable_entity }
          format.json
        end
      end
    end
  end
end
