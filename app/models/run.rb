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

  # TODO: calculate last page?
  def last_page
    return self.page || self.activity.pages.first
  end

  # TODO: generate storage keys?
  # This was intended to generate a list of keys corresponding to each embeddable/question in an activity, to be used by local browser storage. We won't need this until we return to local storage.
  def storage_keys
    []
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

  def all_responses_for_portal
    (self.open_response_answers.map { |ora| ora.portal_hash } + self.multiple_choice_answers.map { |mca| mca.portal_hash }).to_json
  end

  def send_to_portal(answers)
    payload = response_for_portal(answers)
    if !payload.blank? and !self.remote_endpoint.blank?
      # TODO: Post payload to portal
    end
  end

  # TODO: do we ever want to call this?
  def responses
    {
      'multiple_choice_answers' => self.multiple_choice_answers,
      'open_response_answers' => self.open_response_answers
    }
  end

end
