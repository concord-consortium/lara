class LightweightActivity < ActiveRecord::Base
  PUB_STATUSES   = %w(draft private public archive)
  QUESTION_TYPES = [Embeddable::OpenResponse, Embeddable::ImageQuestion, Embeddable::MultipleChoice]

  attr_accessible :name, :publication_status, :user_id, :pages, :related, :description,
    :is_official, :time_to_complete, :is_locked, :notes, :thumbnail_url, :theme_id, :project_id

  belongs_to :user # Author
  belongs_to :changed_by, :class_name => 'User'

  has_many :pages, :foreign_key => 'lightweight_activity_id', :class_name => 'InteractivePage', :order => :position
  has_many :lightweight_activities_sequences, :dependent => :destroy
  has_many :sequences, :through => :lightweight_activities_sequences
  belongs_to :theme
  belongs_to :project

  default_value_for :publication_status, 'draft'
  # has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

  validates :publication_status, :inclusion => { :in => PUB_STATUSES }
  validates_length_of :name, :maximum => 50

  # * Find all public activities
  scope :public, where(:publication_status => 'public')

  # * Find all activities for one user (regardless of publication status)
  def self.my(user)
    where(:user_id => user.id)
  end

  # * Find all activities visible (readable) to the given user
  def self.can_see(user)
    if user.is_admin?
      return LightweightActivity.all
    else
      return LightweightActivity.public + LightweightActivity.my(user)
    end
  end

  # Returns an array of embeddables which are questions (i.e. Open Response or Multiple Choice)
  def questions
    q = []
    pages.each do |p|
      p.embeddables.each do |e|
        if QUESTION_TYPES.include? e.class
          q << e
        end
      end
    end
    return q
  end
  
  # Returns an array of strings representing the storage_keys of all the questions
  def question_keys
    return questions.map { |q| q.storage_key }
  end

  def answers(run)
    finder = Embeddable::AnswerFinder.new(run)
    questions.map { |q| finder.find_answer(q) }
  end

  def set_user!(receiving_user)
    update_attribute(:user_id, receiving_user.id)
  end

  def publish!
    update_attribute(:publication_status, 'public')
  end

  def to_hash
    # We're intentionally not copying:
    # - Publication status (the copy should start as draft like everything else)
    # - user_id (the copying user should be the owner)
    # - Pages (associations will be done differently)
    {
      name: name,
      related: related,
      description: description,
      time_to_complete: time_to_complete
    }
  end

  def duplicate
    new_activity = LightweightActivity.new(self.to_hash)
    # Clarify name
    new_activity.name = "Copy of #{new_activity.name}"
    if new_activity.name.length > 50
      new_activity.name = "#{new_activity.name[0..46]}..."
    end
    self.pages.each do |p|
      new_page = p.duplicate
      new_activity.pages << new_page
      new_page.set_list_position(p.position)
    end
    return new_activity
    # N.B. the duplicate hasn't been saved yet
  end
end
