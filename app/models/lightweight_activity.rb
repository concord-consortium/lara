class LightweightActivity < ActiveRecord::Base
  QUESTION_TYPES = [Embeddable::OpenResponse, Embeddable::ImageQuestion, Embeddable::MultipleChoice]
  include Publishable # models/publishable.rb defines pub & official

  attr_accessible :name, :user_id, :pages, :related, :description,
  :time_to_complete, :is_locked, :notes, :thumbnail_url, :theme_id, :project_id

  belongs_to :user # Author
  belongs_to :changed_by, :class_name => 'User'

  has_many :pages, :foreign_key => 'lightweight_activity_id', :class_name => 'InteractivePage', :order => :position
  has_many :lightweight_activities_sequences, :dependent => :destroy
  has_many :sequences, :through => :lightweight_activities_sequences
  has_many :runs, :foreign_key => 'activity_id'
  belongs_to :theme
  belongs_to :project

  # has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

  validates_length_of :name, :maximum => 50

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
      new_page.lightweight_activity = new_activity
      new_page.set_list_position(p.position)
    end
    return new_activity
    # N.B. the duplicate hasn't been saved yet
  end

  def serialize_for_portal(host)
    local_url = "#{host}#{Rails.application.routes.url_helpers.activity_path(self)}"
    data = {
      'type' => "Activity",
      "name" => self.name,
      "description" => self.description,
      "url" => local_url,
      "create_url" => local_url
    }

    pages = []
    self.pages.each do |page|
      elements = []
      page.embeddables.each do |embeddable|
        case embeddable
        when Embeddable::OpenResponse
          elements.push({
                          "type" => "open_response",
                          "id" => embeddable.id,
                          "prompt" => embeddable.prompt
                        })
        when Embeddable::ImageQuestion
          elements.push({
                          "type" => "image_question",
                          "id" => embeddable.id,
                          "prompt" => embeddable.prompt
                        })
        when Embeddable::MultipleChoice
          choices = []
          embeddable.choices.each do |choice|
            choices.push({
                           "id" => choice.id,
                           "content" => choice.choice,
                           "correct" => choice.is_correct
                         })
          end
          mc_data = {
            "type" => "multiple_choice",
            "id" => embeddable.id,
            "prompt" => embeddable.prompt,
            "choices" => choices
          }
          elements.push(mc_data)
        else
          # We don't suppoert this embeddable type right now
        end
      end
      pages.push({
                   "name" => page.name,
                   "elements" => elements
                 })
    end

    section = {
      "name" => "#{self.name} Section",
      "pages" => pages
    }

    data["sections"] = [section]
    data
  end

end
