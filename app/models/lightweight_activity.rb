class LightweightActivity < ActiveRecord::Base
  PUB_STATUSES = %w(draft private public archive)

  attr_accessible :name, :publication_status, :user_id, :pages, :related, :description

  belongs_to :user # Author
  belongs_to :changed_by, :class_name => 'User'

  has_many :pages, :foreign_key => 'lightweight_activity_id', :class_name => 'InteractivePage', :order => :position

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

  # Returns an array of embeddables which are questions (i.e. Open Response or Multiple Choice)
  def questions
    q = []
    pages.each do |p|
      p.embeddables.each do |e|
        if e.class == Embeddable::MultipleChoice || e.class == Embeddable::OpenResponse
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

end
