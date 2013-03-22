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
          @activity = @multiple_choice.activity
          update_activity_changed_by unless @activity.nil?
          format.xml { render :edit, :layout => false }
        else
          format.xml { render :xml => @multiple_choice.errors, :status => :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        if @multiple_choice.update_attributes(params[:embeddable_multiple_choice])
          flash[:notice] = 'Multiple choice was successfully updated.'
          redirect_path = request.env['HTTP_REFERER'].sub(/\?.+/, '') # Strip the edit-me param
          @activity = @multiple_choice.activity
          update_activity_changed_by unless @activity.nil?
          format.html { redirect_to(redirect_path) }
          format.xml  { head :ok }
        else
          format.html { render :edit }
          format.xml  { render :xml => @multiple_choice.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def check
    @choice = Embeddable::MultipleChoiceChoice.find(params[:id])
    if request.xhr?
      respond_to do |format|
        format.js { render :json => @choice.to_json }
      end
    else
      respond_to do |format|
        format.html { redirect_to interactive_page_path(@choice.page) unless @choice.page.nil? }
        format.json { render :json => @choice.to_json }
      end
    end
  end

  def add_choice
    @multiple_choice = Embeddable::MultipleChoice.find(params[:id])
    @multiple_choice.add_choice("New choice")
    @embeddable = @multiple_choice
    @activity = @multiple_choice.activity
    update_activity_changed_by unless @activity.nil?
    if request.xhr?
      respond_to do |format|
        @multiple_choice.reload
        format.js { render :json => { :html => render_to_string('edit')}, :content_type => 'text/json' }
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
    @multiple_choice.reload
    @embeddable = @multiple_choice
    @activity = @multiple_choice.activity
    update_activity_changed_by unless @activity.nil?
    if request.xhr?
      respond_to do |format|
        format.js { render :json => { :html => render_to_string('edit')}, :content_type => 'text/json' }
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