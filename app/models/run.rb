class Run < ActiveRecord::Base
  attr_accessible :run_count, :user_id, :key, :activity, :user, :remote_id, :activity_id

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
    :format => { :with => /\A[a-zA-Z0-9]*\z/ },
    :length => { :is => 16 }

  def check_key
    unless key.present?
      self.key = session_guid
    end
  end

  # Generates a GUID for a particular run of an activity
  def session_guid(user = nil)
    if user.present?
      # We're assuming a single user won't generate multiple guids per second - but even
      # if they did, it's fine if they're not unique.
      return Digest::MD5.hexdigest("#{activity.name}_#{user.email}_#{DateTime.now().to_s}")[0..15]
    else
      # Add some pseudo-randomness to make sure they don't overlap with concurrent requests from other users
      return Digest::MD5.hexdigest("#{activity.name}_#{rand.to_s}_#{DateTime.now().to_s}")[0..15]
    end
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
  def storage_keys
    []
  end

  # TODO: do we ever want to call this?
  def responses
    {
      'multiple_choice_answers' => self.multiple_choice_answers,
      'open_response_answers' => self.open_response_answers
    }
  end

end
