# encoding: UTF-8

class QuestionTrackersController < ApplicationController
  before_filter :set_question_tracker, except: [:new, :index, :create]
  before_filter :record_qt_origin

  def index
    @question_trackers = QuestionTracker.all # TODO Limit by user.
  end

  def new
    mc = Embeddable::MultipleChoice.create
    mc.create_default_choices
    @question_tracker = QuestionTracker.create(master_question: mc, name: "My question tracker", description: "for …")
    gon.QuestionTracker = QuestionTracker::Editor.new(@question_tracker).to_json
    render :edit
  end

  def show
    respond_to do |format|
      format.html { }
      format.json { render json: QuestionTracker::Editor.new(@question_tracker).to_json  }
    end
  end

  def edit
  end

  def create
    if(canceled?)
      redirect_or_index
    elsif @question_tracker = QuestionTracker.create(params[:question_tracker])
      @question_tracker.reload
      updated_or_created
    else
      render :edit
    end
  end

  def update
    if(canceled?)
      redirect_or_index
    end
    respond_to do |format|
      format.html do
        if @question_tracker.update_attributes(params['master_question'])
          @question_tracker.reload
          updated_or_created
        end
      end
      format.json do
        render json: QuestionTracker::Editor.new(@question_tracker)
          .update(params['question_tracker'])
          .to_json
      end
    end

  end

  def destroy
    @question_tracker.destroy
    redirect_or_index
  end

  private

  def canceled?
    params[:commit] == "cancel"
  end

  def updated_or_created
    flash[:notice] = "Question Tracker was successfully updated."
    redirect_or_index
  end

  def set_question_tracker
    @question_tracker = QuestionTracker.find(params[:id])
    # Data assigned to `gon` variable will be available for JavaScript code in `window.gon` object.
    # this is used in both the itsi editor and in the standard editor to show the published activity
    gon.QuestionTracker = QuestionTracker::Editor.new(@question_tracker).to_json
  end

  def redirect_or_index
    if session[:qt_origin]
      redirect_to session.delete(:qt_origin)
    else
      redirect_to action: "index"
    end
  end

  def record_qt_origin
    if params[:qt_origin]
      session[:qt_origin] = params.delete(:qt_origin)
    end
  end
end
