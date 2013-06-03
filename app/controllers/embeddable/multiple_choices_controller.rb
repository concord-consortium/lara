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
    @multiple_choice = Embeddable::MultipleChoiceAnswer.find(params[:id]).question
    parse_choices
    build_response

    if request.xhr?
      respond_to do |format|
        format.js { render :json => @response.to_json }
      end
    else
      respond_to do |format|
        format.html { redirect_to interactive_page_path(@choice.page) unless @choice.page.nil? }
        format.json { render :json => @response.to_json }
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

  private
  def parse_choices
    begin
      choice_ids = params[:choices].split(',').map{ |i| i.to_i }
    rescue NoMethodError
      choice_ids = nil
    end

    if choice_ids
      @choices = @multiple_choice.choices.find(choice_ids)
    else
      @choices = []
    end
  end

  def build_response
    if @multiple_choice.multi_answer
      selected_incorrect = @choices.select { |c| !c.is_correct }
      selected_correct = @choices - selected_incorrect
      actual_correct = @multiple_choice.choices.select { |c| c.is_correct }
      if @choices.length == 0
        # No answer
        @response = { prompt: 'Please select an answer before checking.'}
      elsif selected_incorrect.length > 0
        # Incorrect answer(s)
        @response = { prompt: selected_incorrect.map { |w| w.prompt.blank? ? "'#{w.choice}' is incorrect" : w.prompt }.join("; ") }
      elsif selected_correct.length != actual_correct.length and selected_incorrect.length == 0
        # Right answers, but not all
        @response = { prompt: "You're on the right track, but you didn't select all the right answers yet."}
      else selected_correct.length == actual_correct.length
        # All correct
        @response = { choice: true }
      end
    else
      # One answer: sending the choice to get rendered as JSON by the action
      @response = @choice = @choices.first
    end
  end
end