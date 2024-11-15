# encoding: UTF-8

class QuestionTrackersController < ApplicationController
  load_and_authorize_resource
  before_action :record_qt_origin

  def index
    @question_trackers = QuestionTracker.all # TODO Limit by user.
  end

  def new
    mc = Embeddable::MultipleChoice.create
    mc.create_default_choices
    @question_tracker = QuestionTracker.create(master_question: mc, name: "My question tracker", description: "for …")
    prepare_gon(@question_tracker)
    render :edit
  end

  def show
    authorize! :manage, QuestionTracker
    respond_to do |format|
      format.html {
        prepare_gon(@question_tracker)
      }
      format.json { render json: QuestionTracker::Editor.new(@question_tracker).to_json  }
    end
  end

  def edit
    prepare_gon(@question_tracker)
    # renders edit form for @question_tracker
  end

  def update_params
    params.require(:question_tracker).permit(:master_question, :questions, :name, :description, :user)
  end

  def update
    respond_to do |format|
      # no support for html.
      format.json do
        render json: QuestionTracker::Editor.new(@question_tracker)
          .update(update_params)
          .to_json
      end
    end
  end

  def destroy
    @question_tracker.destroy
    redirect_or_index
  end


  private

  def prepare_gon(question_tracker)
    # Data assigned to `gon` variable will be available for JavaScript code in `window.gon` object.
    # this is used in the Question Tracker editor react views.
    gon.QuestionTracker = QuestionTracker::Editor.new(question_tracker).to_json
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
