class LightweightActivity < ActiveRecord::Base
  QUESTION_TYPES = [Embeddable::OpenResponse, Embeddable::ImageQuestion, Embeddable::MultipleChoice]
  include Publishable # models/publishable.rb defines pub & official

  attr_accessible :name, :user_id, :pages, :related, :description,
  :time_to_complete, :is_locked, :notes, :thumbnail_url, :theme_id, :project_id,
  :portal_run_count

  belongs_to :user # Author
  belongs_to :changed_by, :class_name => 'User'

  has_many :pages, :foreign_key => 'lightweight_activity_id', :class_name => 'InteractivePage', :order => :position
  has_many :lightweight_activities_sequences, :dependent => :destroy
  has_many :sequences, :through => :lightweight_activities_sequences
  has_many :runs, :foreign_key => 'activity_id'
  belongs_to :theme
  belongs_to :project

  # has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

  # validates_length_of :name, :maximum => 50
  validates :description, :related, :html => true

  # Just a way of getting self.pages with the embeddables eager-loaded
  def pages_with_embeddables
    return InteractivePage.includes(:interactive_items, :page_items => :embeddable).where(:lightweight_activity_id => self.id)
  end

  # Returns an array of embeddables which are questions (i.e. Open Response or Multiple Choice)
  def questions
    q = []
    pages_with_embeddables.each do |p|
      p.embeddables.each do |e|
        if QUESTION_TYPES.include? e.class
          q << e
        end
      end
      p.interactives.each do |i|
        q << i if i.respond_to?('save_state') && i.save_state
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

  def name_with_id
    "#{self.id}. #{self.name}"
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
      time_to_complete: time_to_complete,
      project_id: project_id,
      theme_id: theme_id,
      thumbnail_url: thumbnail_url,
      notes: notes
    }
  end

  def duplicate(new_owner)
    new_activity = LightweightActivity.new(self.to_hash)
    LightweightActivity.transaction do
      new_activity.save!(validate: false)
      # Clarify name
      new_activity.name = "Copy of #{new_activity.name}"
      new_activity.user = new_owner
      self.pages.each do |p|
        new_page = p.duplicate
        new_page.lightweight_activity = new_activity
        new_page.set_list_position(p.position)
        new_page.save!(validate: false)
      end
      new_activity.fix_page_positions
    end
    return new_activity
  end

  # TODO: Include acts_as_list? @pjmorse would hate that.
  def position(seq)
    seq.activities.each_with_index do |a,i|
      return i+1 if a.id == self.id
    end
  end

  def serialize_for_portal(host)
    local_url = "#{host}#{Rails.application.routes.url_helpers.activity_path(self)}"
    data = {
      'type' => "Activity",
      "name" => self.name,
      "description" => self.description,
      "url" => local_url,
      "create_url" => local_url,
      "thumbnail_url" => thumbnail_url
    }

    pages = []
    self.pages.each do |page|
      elements = []
      (page.embeddables + page.interactives).each do |embeddable|
        case embeddable
          # Why aren't we using the to_hash methods for each embeddable here?
          # Probably because they don't include the "type" attribute
        when Embeddable::OpenResponse
          elements.push({
                          "type" => "open_response",
                          "id" => embeddable.id,
                          "prompt" => embeddable.prompt,
                          "is_required" => embeddable.is_prediction
                        })
        when Embeddable::ImageQuestion
          elements.push({
                          "type" => "image_question",
                          "id" => embeddable.id,
                          "prompt" => embeddable.prompt,
                          "drawing_prompt" => embeddable.drawing_prompt,
                          "is_required" => embeddable.is_prediction
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
            "choices" => choices,
            "is_required" => embeddable.is_prediction
          }
          elements.push(mc_data)
        when MwInteractive
          if embeddable.save_state && embeddable.has_report_url
            iframe_data = embeddable.to_hash
            iframe_data["type"] = 'iframe_interactive'
            iframe_data["id"] = embeddable.id
            elements.push(iframe_data)
          end
        else
          # We don't support this embeddable type right now
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

  def for_sequence(seq)
    lightweight_activities_sequences.detect { |a| a.sequence_id  == seq.id}
  end

  def active_runs
    # stored in lightweight_activities table, incremented by run-model
    self.portal_run_count
  end

  def fix_page_positions
    self.pages.map { |page| page.set_list_position(self.pages.index(page)+1) }
  end

  def fix_broken_portal_runs(auth_key=nil)
    success_count = 0
    fail_count = 0
    self.runs.select { |run| !run.remote_endpoint.blank?}.each do |run|
      if run.submit_answers_now(auth_key)
        success_count = success_count + 1
      else
        fail_count = fail_count + 1
      end
    end
    Rails.logger.info("fix broken portal runs for activity #{self.id} fail_count: #{fail_count} success_count: #{success_count}")
    return { activity_id: self.id, fail_count: fail_count, success_count: success_count}
  end

end
