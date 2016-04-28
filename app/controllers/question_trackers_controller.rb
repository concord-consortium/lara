class QuestionTrackersController < ApplicationController
  before_filter :set_question_tracker, except: [:new, :index, :create]
  before_filter :record_qt_origin

  def index
    @question_trackers = QuestionTracker.all # TODO Limit by user.
  end

  def new
    @question_tracker = QuestionTracker.new
    render :edit
  end

  def show
  end

  def edit
  end

  def create
    if(canceled?)
      redirect_to(redirect_location)
    elsif @question_tracker = QuestionTracker.create(params[:question_tracker])
      @question_tracker.reload
      updated_or_created
    else
      render :edit
    end
  end

  def update
    if(canceled?)
      redirect_to redirect_location
    elsif @question_tracker.update_attributes(params[:question_tracker])
      @question_tracker.reload
      updated_or_created
    end
  end

  def replace_master
    begin
      @question_tracker.master_question = params[:embeddable_type].constantize.create
      @question_tracker.save
      flash[:info] = "added new question"
    rescue
      flash[:warning] = "unable to find your question" # Todo
    end
    binding.pry

  end

  def edit_embeddable_redirect(embeddable)
    @question_tracker.add_embeddable(embeddable)
    case embeddable
      when Embeddable::MultipleChoice
        embeddable.create_default_choices
        param = { :edit_embed_mc => embeddable.id }
      when Embeddable::OpenResponse
        param = { :edit_embed_or => embeddable.id }
      when Embeddable::ImageQuestion
        param = { :edit_embed_iq => embeddable.id }
      when Embeddable::Labbook
        param = { :edit_embed_lb => embeddable.id }
    end
    # Add parameter to open new embeddable modal
    redirect_to edit_activity_page_path(@activity, @page, param)
  end

  private
  def canceled?
    params[:commit] == "cancel"
  end

  def updated_or_created
    flash[:notice] = "Question Tracker was successfully updated."
    redirect_to redirect_location
  end

  def set_question_tracker
    @question_tracker = QuestionTracker.find(params[:id])
  end

  def redirect_location
    if session[:qt_origin]
      return session.delete(:qt_origin)
    else
      return "/"
    end
  end

  def record_qt_origin
    if params[:qt_origin]
      session[:qt_origin] = params.delete(:qt_origin)
    end
  end
end
