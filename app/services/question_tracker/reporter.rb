class QuestionTracker::Reporter
  attr_accessor :runs
  attr_accessor :answers
  attr_accessor :questions
  attr_accessor :question_tracker

  # Return a list of tracked questions in an activity to report on.
  def self.question_trackers_for_activity(activity)
    return activity.questions.select{ |q| q.respond_to?(:question_tracker)}.map {|q| q.question_tracker }.compact.uniq
  end

  def self.question_trackers_for_sequence(sequence)
    return sequence.activities.map{ |a| self.question_trackers_for_activity(a)}.flatten.compact.uniq
  end

  # Return a list of all tracked questions
  def self.list()
    QuestionTracker.all
  end

  def self.tracker_json(tracker)
    {
      id: tracker.id,
      name: tracker.name,
      questions: tracker.questions.count,
      master: tracker.master_question_info
    }
  end

  def initialize(question_tracker, learner_json=nil )
    # TODO: learner_json (should be run list)

    self.question_tracker = question_tracker
    self.questions = question_tracker.questions

    # TODO Limit returned answers by matched runs
    self.answers = question_tracker.questions.flat_map { |q| q.answers }
    self.answers.map! { |ans| answer_hash(ans) }
  end

  def report_info
    {
        name: question_tracker.name,
        description: question_tracker.description,
        prompt: question_tracker.master_question.prompt,
        info: question_tracker.master_question_info,
        id: question_tracker.id
    }
  end

  def answer_hash(ans)
    {
        "question_id" => ans.question.id,
        "prompt" => ans.question.prompt,
        "activity_id" => ans.question.activity.id,
        "activity_name" => ans.question.activity.name,
        "endpoint" => ans.run.remote_endpoint,
        "lara_user_id" => ans.run.user_id,
        "answer_hash" => ans.portal_hash,
        "updated_int" => ans.updated_at.to_i,
        "updated_str" => ans.updated_at
    }
  end

end
