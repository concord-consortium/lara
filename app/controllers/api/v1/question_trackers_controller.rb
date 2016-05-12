class Api::V1::QuestionTrackersController < ApplicationController

  def index
    list = QuestionTracker::Reporter.list.map {|tracker| QuestionTracker::Reporter.tracker_json(tracker)}
    render :json => list
  end

  def find
    activity = LightweightActivity.find(params[:activity_id])
    list = QuestionTracker::Reporter.tracked_questions_for_activity(activity).map do |tracker|
      QuestionTracker::Reporter.tracker_json(tracker)
    end
    render :json => list
  end

  def report
    tracker = QuestionTracker.find(params[:question_tracker_id])
    reporter = QuestionTracker::Reporter.new(tracker)
    render :json => {
        "question_tracker" => reporter.report_info,
        "answers" => reporter.answers
    }
  end
end