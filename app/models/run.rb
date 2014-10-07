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

  has_many :interactive_run_states

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
    open_response_answers + multiple_choice_answers + image_question_answers
  end

  def answers_hash
    answers.map {|a| a.portal_hash}
  end

  def clear_answers
    # It can be beneficial, particularly for authors, to come to a page/activity
    # with previous answers erased, so let's make it easy to clear them.
    answers.each { |a| a.destroy }
  end

  def all_responses_for_portal
    answers_hash.to_json
  end

  def oauth_token
    return user.authentication_token if user
    # TODO: throw "no oauth_token for runs without users"
    # TODO: we actually need to check & maintain expiration of this token as well
  end

  def bearer_token
    'Bearer %s' % oauth_token
  end

  # TODO: Alias to all_responses_for_portal
  def responses
    {
      'multiple_choice_answers' => self.multiple_choice_answers,
      'open_response_answers' => self.open_response_answers,
      'image_question_answers' => self.image_question_answers
    }
  end

  # return true if we want to take this run out of the queue: either for success, or any
  # other case where retrying is pointless (e.g. nowhere to send the data, no data to send).
  def send_to_portal(answers, auth_token=nil)
    return true if remote_endpoint.nil? || remote_endpoint.blank? # Drop it on the floor
    payload = response_for_portal(answers)
    return true if payload.nil? || payload.blank? # Pretend we sent it, nobody will notice
    # Use a supplied token if there is one, otherwise check the run's own token
    auth_token ||= bearer_token
    # TODO: This needs more careful treatment.
    # If there is no auth token here, we actually need to stop trying to push to the portal and
    # avoid the Delayed Job falloff cycle. If we get into the falloff cycle, a user might
    # log in and provide a valid token, but then have that new token expire before DelayedJob
    # retries the job.
    # Something like this, but this is incomplete.
    # if auth_token.blank? # TODO: Or expired, when we know how to check that.
    #   raise InvalidJobState, "No authentication token - try re-authenticating"
    # end
    response = HTTParty.post(
      remote_endpoint, {
        :body => payload,
        :headers => {
          "Authorization" => auth_token,
          "Content-Type" => 'application/json'
        }
      }
    )
    # TODO: better error detection?
    response.success?
  end

  def queue_for_portal(answer, auth_key=nil)
    return false if remote_endpoint.nil? || remote_endpoint.blank?
    return false if answers.nil?
    if dirty?
      # no-op: only queue one time
    else
      mark_dirty
      submit_dirty_answers(auth_key) #will happen asyncronously sometime in the future...
    end
  end

  def dirty_answers
    # Returns an array of answers which have a dirty bit set
    return answers.select{ |a| a.dirty? }
  end

  def abort_job_and_requeue
    # If a method throws an exception it will be rerun later.
    # The method will be retried up to 25 times with exp. falloff.
    raise PortalUpdateIncomplete.new
  end

  def submit_answers_now(auth_key=nil)
    if send_to_portal(self.answers, auth_key)
      set_answers_clean(self.answers)
      self.reload
      if dirty_answers.empty?
        self.mark_clean
        return true
      end
    end
    return false
  end

  def submit_dirty_answers(auth_key=nil)
    # Find array of dirty answers and send them to the portal
    da = dirty_answers
    return if da.empty?
    if send_to_portal da, auth_key
      set_answers_clean da # We're only cleaning the same set we sent to the portal
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

  def num_answers
    return self.answers.size
  end

  def completed?
    return self.num_answers == num_questions
  end

  def percent_complete
    return (num_answers / Float(num_questions) ) * 100.0
  end

end
