class QuestionTracker::LearnerRecord

  attr_accessor :clazz
  attr_accessor :clazz_id
  attr_accessor :teacher
  attr_accessor :activity
  attr_accessor :name
  attr_accessor :username
  attr_accessor :endpoint_url

  def initialize(data={})
    self.clazz        = data["clazz"]        || "no class name"
    self.clazz_id     = data["clazz_id"]     || "0"
    self.teacher      = data["teacher"]      || "no teacher name"
    self.activity     = data["activity"]     || "no activity"
    self.name         = data["name"]         || "no name"
    self.username     = data["username"]     || "no name"
    self.endpoint_url = data["endpoint_url"] || nil
  end

  def self.from_json(json)
    offering_array = JSON.parse(json)
    offering_array.flat_map do |offering|
      class_info = {
          "clazz"    => offering['clazz'],
          "clazz_id" => offering['clazz_id'],
          "activity" => offering['activity'],
          "teacher"  => offering['teacher']
      }
      offering['students'].map do |student_hash|
        self.new(student_hash.merge(class_info))
      end
    end
  end
end

class QuestionTracker::Reporter

  attr_accessor :runs
  attr_accessor :answers
  attr_accessor :questions
  attr_accessor :question_tracker
  attr_accessor :learner_map

  # Return a list of tracked questions in an activity to report on.
  def self.question_trackers_for_activity(activity)
    return activity.questions.map{ |q| q.question_tracker }.compact.uniq
  end


  # Return a list of all tracked questions
  def self.list()
    QuestionTracker.all
  end

  def self.tracker_json(tracker)
    {
      id: tracker.id,
      name: tracker.name,
      questions: tracker.questions.size,
      master: tracker.master_question_info
    }
  end

  def initialize(question_tracker, learner_json="[]")
    self.learner_map = {}
    QuestionTracker::LearnerRecord.from_json(learner_json).each do |lr|
      self.learner_map[lr.endpoint_url]  ||= lr
    end

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
        info: question_tracker.master_question_info
    }
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
        "username" => user_record.username,
        "lara_user_id" => ans.run.user_id,
        "student_name" => user_record.name,
        "clazz" => user_record.clazz,
        "clazz_id" => user_record.clazz_id,
        "teacher" => user_record.teacher,
        "answer_hash" => ans.portal_hash,
        "updated_int" => ans.updated_at.to_i,
        "updated_str" => ans.updated_at
    }
  end

  def lookup_user(endpoint_url)
    return learner_map[endpoint_url] || QuestionTracker::LearnerRecord.new({endpoint_url: [endpoint_url]})
  end
end
