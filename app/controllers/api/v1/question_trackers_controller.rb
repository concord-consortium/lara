class Api::V1::QuestionTrackersController < ApplicationController

  def index
    render json: trackers_json(QuestionTracker.all)
  end

  def find_by_activity
    activity = LightweightActivity.find(params[:activity_id])
    list = QuestionTracker::Reporter.question_trackers_for_activity(activity)
    render json: trackers_json(list)
  end

  def find_by_sequence
    sequence = Sequence.find(params[:sequence_id])
    list = QuestionTracker::Reporter.question_trackers_for_sequence(sequence)
    render json: trackers_json(list.flatten)
  end

  def report
    tracker = QuestionTracker.find(params[:question_tracker_id])
    reporter = QuestionTracker::Reporter.new(tracker, params[:endpoints])
    render json: reporter.report
  end

  private
  def trackers_json(trackers)
    trackers.map do |tracker|
      {
        id: tracker.id,
        name: tracker.name,
        questions: tracker.questions.count,
        master: tracker.master_question_info,
        report_url: api_v1_question_tracker_report_url(tracker.id)
      }
    end
  end
end