class QuestionTracker::LearnerRecord
  attr_accessor :student_name
  attr_accessor :student_id
  attr_accessor :class_name
  attr_accessor :class_id
  attr_accessor :teacher_name
  attr_accessor :teacher_id
  attr_accessor :endpoints
  attr_accessor :email

  def initialize(hash_values={})
    self.student_name     = hash_values["student_name"]     || "no name"
    self.student_id       = hash_values["student_id"]       || "no name"
    self.class_name       = hash_values["class_name"]       || "no class name"
    self.class_id         = hash_values["class_id"]         || "0"
    self.teacher_name     = hash_values["teacher_name"]     || "no teacher name"
    self.teacher_id       = hash_values["teacher_id"]       || "0"
    self.endpoints        = hash_values["endpoints"]        || []
  end

  def self.from_json(json)
    hash_array = JSON.parse(json)
    hash_array.map { |h| self.new(h) }
  end
end

class QuestionTracker::Reporter
  attr_accessor :runs
  attr_accessor :answers
  attr_accessor :questions
  attr_accessor :question_tracker
  attr_accessor :learner_map

  # Return a list of tracked questions in an activity to report on.
  def self.tracked_questions_for_activity(activity)
    return activity.questions.select  {|q| q.question_tracker}
  end

  def initialize(question_tracker, learner_json)
    self.learner_map = {}
    QuestionTracker::LearnerRecord.from_json(learner_json).each do |lr|
      lr.endpoints.each do |endpoint|
        self.learner_map[endpoint] = lr
      end
    end

    self.question_tracker = question_tracker
    self.questions = question_tracker.questions
    self.answers = question_tracker.questions.flat_map { |q| q.answers }
    self.answers.map! { |ans| answer_hash(ans) }
  end

  def answer_hash(ans)
    user_record = lookup_user(ans.run.remote_endpoint)
    {
        "page_id" => ans.question.interactive_pages.first.id,
        "question_id" => ans.question.id,
        "prompt" => ans.question.prompt,
        "activity_id" => ans.question.activity.id,
        "activity_name" => ans.question.activity.name,
        "endpoint" => ans.run.remote_endpoint,
        "student_id" => user_record.student_id,
        "lara_user_id" => ans.run.user_id,
        "student_name" => user_record.student_name,
        "class_name" => user_record.class_name,
        "class_id" => user_record.class_id,
        "teacher_id" => user_record.teacher_id,
        "teacher_name" => user_record.teacher_name,
        "answer_hash" => ans.portal_hash
    }
  end

  def lookup_user(remote_endpoint)
    return learner_map[remote_endpoint] || QuestionTracker::LearnerRecord.new({remote_endpoints: [remote_endpoint]})
  end
end
