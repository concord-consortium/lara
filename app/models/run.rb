class Run < ActiveRecord::Base
  attr_accessible :run_count, :user_id, :key, :activity, :user

  belongs_to :activity, :class_name => LightweightActivity

  belongs_to :user

  has_many :multiple_choice_answers,
    :class_name  => 'Embeddable::MultipleChoiceAnswer',
    :foreign_key => 'run_id',
    :dependent   => :destroy

  has_many :open_response_answers,
    :class_name  => 'Embeddable::OpenResponseAnswer',
    :foreign_key => 'run_id',
    :dependent => :destroy

  before_validation :check_key
  validates :key, :format => { :with => /\A[a-zA-Z0-9]*\z/ }, :length => { :is => 16 }

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

  def to_param
    key
  end

  # TODO: calculate last page?
  def last_page
    "TODO: calculate last page?"
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
