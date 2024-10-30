class QuestionTracker::Reporter
  attr_accessor :answers
  attr_accessor :question_tracker

  # Return a list of tracked questions in an activity to report on.
  def self.question_trackers_for_activity(activity)
    return activity.reportable_items.select{ |q| q.respond_to?(:question_tracker)}.map {|q| q.question_tracker }.compact.uniq
  end

  def self.question_trackers_for_sequence(sequence)
    return sequence.activities.map{ |a| self.question_trackers_for_activity(a)}.flatten.compact.uniq
  end

  def initialize(_question_tracker, endpoints)
    self.question_tracker = _question_tracker

    runs = []

    master_question = self.question_tracker.master_question
    foreign_key = master_question._reflections[:answers].foreign_key.to_sym
    answer_class_name = master_question._reflections[:answers].class_name
    answer_class = answer_class_name.constantize

    question_ids = self.question_tracker.tracked_questions.pluck(:question_id)

    if (endpoints && endpoints.kind_of?(Array))
      run_ids = Run.where(remote_endpoint: endpoints).pluck(:id)

      self.answers = answer_class.where(
        :run_id => run_ids,
        foreign_key => question_ids).includes(:question, :run).to_a
    else
      self.answers = []
    end

    self.answers.map! { |ans| answer_hash(ans) }
  end

  def report
    {
      question_tracker: report_info,
      questions: question_tracker.questions.map(&:portal_hash),
      answers: answers
    }
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
