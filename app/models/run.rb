class Run < ActiveRecord::Base
  attr_accessible :run_count, :user_id, :key, :activity, :user, :remote_id, :remote_endpoint, :activity_id

  belongs_to :activity, :class_name => LightweightActivity

  belongs_to :user

  belongs_to :page, :class_name => InteractivePage # last page

  has_many :multiple_choice_answers,
    :class_name  => 'Embeddable::MultipleChoiceAnswer',
    :foreign_key => 'run_id',
    :dependent   => :destroy

  has_many :open_response_answers,
    :class_name  => 'Embeddable::OpenResponseAnswer',
    :foreign_key => 'run_id',
    :dependent => :destroy

  before_validation :check_key

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

  def self.for_key(key)
    return nil if key.nil?
    self.by_key(key).first
  end

  def self.for_user_activity_and_remote_id(user,activity,remote_id)
    conditions = {
      :user_id => user.id,
      :activity_id => activity.id
    }
    conditions[:remote_id] = remote_id if remote_id
    found = self.find(:first, :conditions => conditions)
    return found || self.create(conditions)
  end

  def self.lookup(key,activity,user=nil,remote_id=nil)
    return self.for_key(key) if key
    return self.for_user_activity_and_remote_id(user,activity,remote_id) if user
    return self.create(:activity => activity, :remote_id => :remote_id)
  end

  def to_param
    key
  end

  def last_page
    return self.page || self.activity.pages.first
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
    open_response_answers + multiple_choice_answers
  end

  def answers_hash
    answers.map {|a| a.portal_hash}
  end

  def all_responses_for_portal
    answers_hash.to_json
  end

  def oauth_token
    return user.authentication_token if user
    # TODO: throw "no oauth_token for runs without users"
  end

  # TODO: Alias to all_responses_for_portal
  def responses
    {
      'multiple_choice_answers' => self.multiple_choice_answers,
      'open_response_answers' => self.open_response_answers
    }
  end

  # return true if we saved.
  def send_to_portal(answers)
    return false if remote_endpoint.nil? || remote_endpoint.blank?
    payload = response_for_portal(answers)
    return false if payload.nil? || payload.blank?
    bearer_token = 'Bearer %s' % oauth_token
    response = HTTParty.post(
      remote_endpoint, {
        :body => payload,
        :headers => {
          "Authorization" => bearer_token,
          "Content-Type" => 'application/json'
        }
      }
    )
    # TODO: better error detection?
    response.code == 200
  end

end
