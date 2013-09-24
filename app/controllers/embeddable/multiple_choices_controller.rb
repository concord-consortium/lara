class Embeddable::MultipleChoicesController < ApplicationController
  before_filter :set_embeddable, :except => [:check, :remove_choice]

  def edit
    respond_to do |format|
      format.js { render :json => { :html => render_to_string('edit')}, :content_type => 'text/json' }
      format.html
    end
  end

  def update
    cancel = params[:commit] == "Cancel"
    updated = @embeddable.update_attributes(params[:embeddable_multiple_choice])
    if updated
      update_activity_changed_by(@embeddable.activity) unless @embeddable.activity.nil?
      @embeddable.reload
      flash[:notice] = 'Multiple choice was successfully updated.'
    end
    respond_to do |format|
      if cancel || updated
        if request.xhr?
          format.xml { render :edit, :layout => false }
        else
          format.html { redirect_to(request.env['HTTP_REFERER'].sub(/\?.+/, '')) } # Strip the edit-me param
          format.xml  { head :ok }
        end
      else
        format.html { render :edit }
        format.xml { render :xml => @embeddable.errors, :status => :unprocessable_entity }
      end
    end
  end

  def check
    @multiple_choice = Embeddable::MultipleChoiceAnswer.find(params[:id]).question
    parse_choices
    build_response # sets @choice

    respond_to do |format|
      if request.xhr?
        format.js { render :json => @response.to_json }
      else
        format.html { redirect_to interactive_page_path(@choice.page) unless @choice.page.nil? }
        format.json { render :json => @response.to_json }
      end
    end
  end

  def add_choice
    @embeddable.add_choice("New choice")
    update_activity_changed_by(@embeddable.activity) unless @embeddable.activity.nil?
    respond_to do |format|
      if request.xhr?
        @embeddable.reload
        format.js { render :json => { :html => render_to_string('edit')}, :content_type => 'text/json' }
      else
        flash[:notice] = 'New choice was added.'
        format.html { redirect_to(:back) }
        format.xml  { head :ok }
        format.json
      end
    end
  end

  def remove_choice
    @embeddable.choices.find(params[:choice_id]).destroy
    @embeddable.reload
    update_activity_changed_by(@embeddable.activity) unless @embeddable.activity.nil?
    respond_to do |format|
      if request.xhr?
        format.js { render :json => { :html => render_to_string('edit')}, :content_type => 'text/json' }
      else
        flash[:notice] = 'Choice was removed.'
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
      @choices = @multiple_choice.choices.find(choice_ids)
    rescue NoMethodError
      @choices = []
    end
  end

  def build_response
    # TODO: can this be refactored into the model?
    # @choice needs to be set anyway
    @choice = @choices.first
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
      @response = @choice
    end
  end

  def set_embeddable
    @embeddable = Embeddable::MultipleChoice.find(params[:id], :include => :choices)
  end
end