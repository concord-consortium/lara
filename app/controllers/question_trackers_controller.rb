# encoding: UTF-8

class QuestionTrackersController < ApplicationController
  before_filter :set_question_tracker, except: [:new, :index, :create]
  before_filter :record_qt_origin

  def index
    authorize! :manage, QuestionTracker
    @question_trackers = QuestionTracker.all # TODO Limit by user.
  end

  def new
    authorize! :manage, QuestionTracker
    mc = Embeddable::MultipleChoice.create
    mc.create_default_choices
    @question_tracker = QuestionTracker.create(master_question: mc, name: "My question tracker", description: "for …")
    gon.QuestionTracker = QuestionTracker::Editor.new(@question_tracker).to_json
    gon.DoneLink = session[:qt_origin] || question_trackers_path
    render :edit
  end

  def show
    authorize! :manage, QuestionTracker
    respond_to do |format|
      format.html { }
      format.json { render json: QuestionTracker::Editor.new(@question_tracker).to_json  }
    end
  end

  def edit
    authorize! :manage, QuestionTracker
    # renders edit form for @question_tracker
  end


  def update
    authorize! :manage, QuestionTracker
    respond_to do |format|
      # no support for html.
      format.json do
        # binding.pry
        render json: QuestionTracker::Editor.new(@question_tracker)
          .update(params['question_tracker'])
          .to_json
      end
    end
  end

  def destroy
    authorize! :manage, QuestionTracker
    @question_tracker.destroy
    redirect_or_index
  end


  private

  def set_question_tracker
    @question_tracker = QuestionTracker.find(params[:id])
    # Data assigned to `gon` variable will be available for JavaScript code in `window.gon` object.
    # this is used in both the itsi editor and in the standard editor to show the published activity
    gon.QuestionTracker = QuestionTracker::Editor.new(@question_tracker).to_json
    gon.DoneLink = session[:qt_origin] || question_trackers_path
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
