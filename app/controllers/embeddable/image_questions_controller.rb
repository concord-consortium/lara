class Embeddable::ImageQuestionsController < ApplicationController
  def edit
    @embeddable = Embeddable::ImageQuestion.find(params[:id])
    respond_to do |format|
      format.js { render :json => { :html => render_to_string('edit')}, :content_type => 'text/json' }
      format.html
    end
  end

  # PUT /Embeddable/open_responses/1
  # PUT /Embeddable/open_responses/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @image_question = Embeddable::ImageQuestion.find(params[:id])
    if request.xhr?
      respond_to do |format|
        if cancel || @image_question.update_attributes(params[:embeddable_image_question])
          @activity = @image_question.activity
          update_activity_changed_by unless @activity.nil?
          format.xml { render :partial => 'show', :locals => { :image_question => @image_question } }
          format.json
        else
          format.xml { render :xml => @image_question.errors, :status => :unprocessable_entity }
          format.json
        end
      end
    else
      respond_to do |format|
        if @image_question.update_attributes(params[:embeddable_image_question])
          @activity = @image_question.activity
          update_activity_changed_by unless @activity.nil?
          flash[:notice] = 'Embeddable::ImageQuestion.was successfully updated.'
          redirect_path = request.env['HTTP_REFERER'].sub(/\?.+/, '') # Strip the edit-me param
          format.html { redirect_to(redirect_path) }
          format.xml  { head :ok }
          format.json
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @image_question.errors, :status => :unprocessable_entity }
          format.json
        end
      end
    end
  end

end
