class Run < ActiveRecord::Base

  # Trigger whenever a portal update job needs to be re-run
  class PortalUpdateIncomplete < StandardError; end
  class InvalidJobState < StandardError; end

  attr_accessible :run_count, :user_id, :key, :activity, :user, :remote_id, :remote_endpoint, :activity_id, :sequence_id

  belongs_to :activity, :class_name => LightweightActivity

  belongs_to :user

  belongs_to :page, :class_name => InteractivePage # last page

  belongs_to :sequence # optional

  belongs_to :sequence_run # optional

  belongs_to :collaboration_run # optional

  has_many :multiple_choice_answers,
    :class_name  => 'Embeddable::MultipleChoiceAnswer',
    :foreign_key => 'run_id',
    :dependent   => :destroy

  has_many :open_response_answers,
    :class_name  => 'Embeddable::OpenResponseAnswer',
    :foreign_key => 'run_id',
    :dependent => :destroy

  has_many :image_question_answers,
    :class_name  => 'Embeddable::ImageQuestionAnswer',
    :foreign_key => 'run_id',
    :dependent => :destroy

  has_many :labbook_answers,
    :class_name  => 'Embeddable::LabbookAnswer',
    :foreign_key => 'run_id',
    :dependent => :destroy

  has_many :interactive_run_states

  has_one :global_interactive_state

  before_validation :check_key
  after_create :update_activity_portal_run_count

  scope :by_key, lambda { |k|
      {:conditions => { :key => k } }
    }

  validates :key,
    :format => { :with => /\A[a-zA-Z0-9\-]*\z/ },
    :length => { :is => 36 }

  def check_key
    unless key.present?
      self.key = session_guid
    end
  end

  # Generates a GUID for a particular run of an activity
  def session_guid
    UUIDTools::UUID.random_create.to_s
  end

  def self.for_user_activity_and_sequence(user,activity,seq_id)
    conditions = {
      activity_id:     activity.id,
      user_id:         user.id,
      sequence_id:     seq_id
    }
    found = self.find(:first, :conditions => conditions)
    return found || self.create(conditions)
  end

  def self.for_user_and_portal(user,activity,portal)
    conditions = {
      remote_endpoint: portal.remote_endpoint,
      remote_id:       portal.remote_id,
      user_id:         user.id
      #TODO: add domain
    }
    conditions[:activity_id]     = activity.id if activity
    found = self.find(:first, :conditions => conditions)
    return found || self.create(conditions)
  end

  def self.for_user_and_activity(user,activity)
    conditions = {
      activity_id:     activity.id,
      user_id:         user.id
    }
    found = self.find(:first, :conditions => conditions)
    return found || self.create(conditions)
  end

  def self.for_key(key, activity)
    self.by_key(key).first || self.create(activity: activity)
  end

  def self.lookup(key, activity, user, portal,seq_id)
    return self.for_user_and_portal(user, activity, portal) if user && portal && portal.valid?
    return self.for_key(key, activity) if (key && activity)
    return self.for_user_activity_and_sequence(user,activity,seq_id) if (user && activity && seq_id)
    return self.for_user_and_activity(user,activity) if (user && activity)
    return self.create(activity: activity)
  end

  def self.auth_provider(remote_endpoint)
    uri = URI.parse(remote_endpoint)
    auth_url = (uri.port == 80) ? "#{uri.scheme}://#{uri.host}" : "#{uri.scheme}://#{uri.host}:#{uri.port}"
    ENV['CONFIGURED_PORTALS'].split.each do |cp|
      if ENV["CONCORD_#{cp}_URL"] == auth_url
        return cp
      end
      return nil
    end
  end

  def to_param
    key
  end

  def get_auth_provider
    self.remote_endpoint.blank? ? nil : Run.auth_provider(self.remote_endpoint)
  end

  def last_page
    return self.page
  end

  def has_been_run
    return run_count && run_count > 0
  end

  def increment_run_count!
    self.run_count ||= 0
    increment!(:run_count)
  end

  # Takes an answer or array of answers and generates a portal response JSON string from them.
  def response_for_portal(answer)
    if answer.kind_of?(Array)
      answer.map { |ans| ans.portal_hash }.to_json
    else
      "[#{answer.portal_hash.to_json}]"
    end
  end

  def answers
    open_response_answers + multiple_choice_answers + image_question_answers + labbook_answers + interactive_run_states
  end

  def answers_hash
    answers.map {|a| a.portal_hash}
  end

  def clear_answers
    # It can be beneficial, particularly for authors, to come to a page/activity
    # with previous answers erased, so let's make it easy to clear them.
    answers.each { |a| a.destroy }
    global_interactive_state.destroy
  end

  def all_responses_for_portal
    answers_hash.to_json
  end

  def disable_collaboration
    collaboration_run.disable if collaboration_run
  end

  # TODO: Alias to all_responses_for_portal
  def responses
    {
      'multiple_choice_answers' => self.multiple_choice_answers,
      'open_response_answers' => self.open_response_answers,
      'image_question_answers' => self.image_question_answers,
      'external_links' => self.interactive_run_states
    }
  end

  # return true if we want to take this run out of the queue: either for success, or any
  # other case where retrying is pointless (e.g. nowhere to send the data, no data to send).
  def send_to_portal(answers)
    return true if remote_endpoint.nil? || remote_endpoint.blank? # Drop it on the floor
    payload = response_for_portal(answers)
    return true if payload.nil? || payload.blank? # Pretend we sent it, nobody will notice
    response = HTTParty.post(
      remote_endpoint, {
        :body => payload,
        :headers => {
          "Authorization" => Concord::AuthPortal.auth_token_for_url(remote_endpoint),
          "Content-Type" => 'application/json'
        }
      }
    )
    # TODO: better error detection?
    is_success = response.success?
    abort_job_and_requeue(error_string_for(response, payload)) unless is_success
    is_success
  end

  def queue_for_portal(answer)
    return false if remote_endpoint.nil? || remote_endpoint.blank?
    return false if answers.nil?
    if dirty?
      # no-op: only queue one time
    else
      mark_dirty
      submit_dirty_answers #will happen asyncronously sometime in the future...
    end
  end

  def dirty_answers
    # Returns an array of answers which have a dirty bit set
    return answers.select{ |a| a.dirty? }
  end

  def abort_job_and_requeue(message="")
    # If a method throws an exception it will be rerun later.
    # The method will be retried up to 25 times with exp. falloff.
    raise PortalUpdateIncomplete.new(message)
  end

  def submit_answers_now
    if send_to_portal(self.answers)
      set_answers_clean(self.answers)
      self.reload
      if dirty_answers.empty?
        self.mark_clean
        return true
      end
    end
    return false
  end

  def submit_dirty_answers
    # Find array of dirty answers and send them to the portal
    da = dirty_answers
    return if da.empty?
    if send_to_portal(da)
      set_answers_clean(da) # We're only cleaning the same set we sent to the portal
      self.reload
      if dirty_answers.empty?
        self.mark_clean
      else
        # I'm not sure about using this method here, because it raises an error when the
        # "problem" may just be that (a) new dirty answer(s) were submitted between the
        # send_to_portal call and the check here.
        abort_job_and_requeue
      end
    else
      abort_job_and_requeue
    end
  end
  handle_asynchronously :submit_dirty_answers, :run_at => Proc.new { 30.seconds.from_now }

  def set_answers_clean(answers=[])
    # Takes an array of answers and sets their is_dirty bits to clean
    answers.each do |answer|
      answer.mark_clean
    end
  end

  def dirty?
    is_dirty
  end

  def mark_dirty
    self.is_dirty = true
    self.save
    # TODO: enqueue
  end

  def mark_clean
    self.is_dirty = false
    self.save
  end

  def update_activity_portal_run_count
    return unless self.activity
    return if self.remote_endpoint.blank?
    self.activity.increment!(:portal_run_count)
  end

  def num_questions
    return self.activity.questions.size
  end

  # HACK for interactive run state saving...
  def question_answers
    self.answers.reject {|a| a.question.kind_of? InteractiveRunState::QuestionStandin}
  end

  def num_answers
    q_answers = activity_q_answers = self.question_answers.reject { |a| a.blank? }
    begin # this really shouldn't happen, but there are some bad runs in the DB
      activity_q_answers = q_answers.reject { |a| a.question.activity.id != self.activity_id }
      unless q_answers.size == activity_q_answers.size
        Rails.logger.error("run #{self.id} has answers from another activity")
      end
    rescue
    end
    return activity_q_answers.size
  end

  def completed?
    return self.num_answers == num_questions
  end

  def percent_complete
    return (num_answers / Float(num_questions) ) * 100.0
  end

  # See PT https://www.pivotaltracker.com/story/show/59365552
  # And stories about run links (can't find it.)
  def remove_answers_to_wrong_activity
    [:multiple_choice_answers, :open_response_answers, :image_question_answers].each do |answer_type|
      answers = self.send answer_type
      answers.each do |answer|
        if answer.question && answer.question.activity
          activity_id = answer.question.activity.id
          unless activity_id == self.activity_id
            answer.delete
            puts "deleted an answer to question: #{answer.question.id}"
          end
        end
      end
    end
  end

  def info
    # begin
      q_activities = question_answers.map { |a| a.question.activity.id}.uniq.join(", ")
      q_activities = "[#{q_activities}]"
      info=<<-EOF
                 run_id: #{id}
                run_key: #{key}
                  dirty: #{dirty?}
        remote_endpoint: #{remote_endpoint}
       percent_complete: #{percent_complete}
      number of answers: #{num_answers}  (#{answers.size})
    number of questions: #{num_questions}
               activity: #{activity.name} [#{activity_id}]
               sequence: #{sequence_id}
          collaboration: #{collaboration_run_id}
           sequence_run: #{sequence_run_id}
             other_runs: #{sequence_run.runs.map { |r| r.id }.join(",") if sequence_run}
   other seq activities: #{sequence_run.runs.map { |r| r.activity_id }.join(",") if sequence_run}
     acitvity questions: #{q_activities}
      EOF
      info.gsub(/^\s+/,'')
    # rescue NameError => e
    # end
  end

  def error_string_for(response, payload)
    error_string = "response_code:#{response.code}\
                    response_message:#{response.message}\
                    payload:#{payload}\
                    remote_endpoint:#{remote_endpoint}\
                    run_id: #{id}\
                    run_key: #{key}\
                    dirty: #{dirty?}\
                    activity: #{activity.name} [#{activity_id}]\
                    sequence: #{sequence_id}"

    error_string
  end

  def lara_to_portal_secret_auth
    return 'Bearer %s' % Concord::AuthPortal.auth_token_for_url(self.remote_endpoint)
  end
end
