class Api::V1::QuestionTrackersController < ApplicationController

  def index
    list = QuestionTracker::Reporter.list.map {|tracker| QuestionTracker::Reporter.tracker_json(tracker)}
    render :json => list.map {|tracker| add_report_url(tracker)}
  end

  def find_by_activity
    activity = LightweightActivity.find(params[:activity_id])
    list = QuestionTracker::Reporter.question_trackers_for_activity(activity).map do |tracker|
      add_report_url(QuestionTracker::Reporter.tracker_json(tracker))
    end
    render :json => list
  end

  def find_by_sequence
    sequence = Sequence.find(params[:sequence_id])
    list = QuestionTracker::Reporter.question_trackers_for_sequence(sequence).map do |tracker|
      add_report_url(QuestionTracker::Reporter.tracker_json(tracker))
    end
    render :json => list.flatten
  end

  def report
    tracker = QuestionTracker.find(params[:question_tracker_id])
    reporter = QuestionTracker::Reporter.new(tracker, params[:endpoints] || nil)
    render :json => {
        "question_tracker" => reporter.report_info,
        "answers" => reporter.answers
    }
  end

  private
  def add_report_url(trackerHash)
    trackerHash.merge(report_url:api_v1_question_tracker_report_url(trackerHash[:id]))
  end

end