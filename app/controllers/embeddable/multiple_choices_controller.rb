class Embeddable::MultipleChoicesController < Embeddable::EmbeddablesController
  before_action :set_embeddable, :except => [:check, :remove_choice]

  def check
    @multiple_choice = Embeddable::MultipleChoiceAnswer.find(params[:id]).question
    @response = @multiple_choice.check(params[:choices])

    respond_to do |format|
      if request.xhr?
        format.js { render :json => @response.to_json }
      else
        format.html { redirect_to interactive_page_path(@multiple_choice.interactive_pages.last) unless @multiple_choice.interactive_pages.last.nil? }
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
  def set_embeddable
    @embeddable = Embeddable::MultipleChoice.includes(:choices).find(params[:id])
  end
end