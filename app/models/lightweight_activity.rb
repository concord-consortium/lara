class LightweightActivity < ActiveRecord::Base
  include Publishable # defines methods to publish to portals
  include PublicationStatus # defines publication status scopes and helpers

  LAYOUT_MULTI_PAGE = 0
  LAYOUT_SINGLE_PAGE = 1
  LAYOUT_OPTIONS = [
    ['Multi-page', LAYOUT_MULTI_PAGE],
    ['Single-page', LAYOUT_SINGLE_PAGE]
  ]
  STANDARD_EDITOR_MODE = 0
  ITSI_EDITOR_MODE = 1
  EDITOR_MODE_OPTIONS = [
    ['Standard', STANDARD_EDITOR_MODE],
    ['ITSI', ITSI_EDITOR_MODE]
  ]

  attr_accessible :name, :user_id, :pages, :related, :description,
                  :time_to_complete, :is_locked, :notes, :thumbnail_url, :theme_id, :project_id,
                  :portal_run_count, :layout, :editor_mode, :publication_hash, :copied_from_id,
                  :external_report_url, :student_report_enabled

  belongs_to :user # Author
  belongs_to :changed_by, :class_name => 'User'

  has_many :pages, :foreign_key => 'lightweight_activity_id', :class_name => 'InteractivePage', :order => :position
  has_many :visible_pages, :foreign_key => 'lightweight_activity_id', :class_name => 'InteractivePage', :order => :position,
             :conditions => {interactive_pages: {is_hidden: false}}

  has_many :lightweight_activities_sequences, :dependent => :destroy
  has_many :sequences, :through => :lightweight_activities_sequences
  has_many :runs, :foreign_key => 'activity_id'
  belongs_to :theme
  belongs_to :project

  has_many :imports, as: :import_item

  belongs_to :copied_from_activity, :class_name => "LightweightActivity", :foreign_key => "copied_from_id"

  # has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

  # validates_length_of :name, :maximum => 50
  validates :description, :related, :html => true

  # Just a way of getting self.visible_pages with the embeddables eager-loaded
  def visible_pages_with_embeddables
    InteractivePage
      .includes(:page_items => :embeddable)
      .where(:lightweight_activity_id => self.id, :is_hidden => false)
      .order(:position)
  end

  def reportable_items
    items = []
    visible_pages_with_embeddables.each do |p|
      items += p.reportable_items
    end
    items
  end

  def answers(run)
    finder = Embeddable::AnswerFinder.new(run)
    reportable_items.map { |q| finder.find_answer(q) }
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
      notes: notes,
      layout: layout,
      editor_mode: editor_mode,
      external_report_url: external_report_url,
      student_report_enabled: student_report_enabled
    }
  end

  def duplicate(new_owner, interactives_cache=nil)
    interactives_cache = InteractivesCache.new if interactives_cache.nil?
    new_activity = LightweightActivity.new(self.to_hash)
    LightweightActivity.transaction do
      new_activity.save!(validate: false)
      # Clarify name
      new_activity.name = "Copy of #{new_activity.name}"
      new_activity.user = new_owner
      new_activity.copied_from_id = self.id
      self.pages.each do |p|
        new_page = p.duplicate(interactives_cache)
        new_page.lightweight_activity = new_activity
        new_page.set_list_position(p.position)
        new_page.save!(validate: false)
      end
      new_activity.fix_page_positions
    end
    return new_activity
  end

  def export
    activity_json = self.as_json(only: [:name,
                                        :related,
                                        :description,
                                        :time_to_complete,
                                        :project_id,
                                        :thumbnail_url,
                                        :notes,
                                        :layout,
                                        :editor_mode,
                                        :external_report_url,
                                        :student_report_enabled
    ])
    activity_json[:version] = 1
    activity_json[:theme_name] = self.theme ? self.theme.name : nil
    activity_json[:pages] = []
    self.pages.each do |p|
      activity_json[:pages] << p.export
    end
    activity_json[:type] = "LightweightActivity"
    activity_json[:export_site] = "Lightweight Activities Runtime and Authoring"
    return activity_json
  end

  def self.extact_from_hash(activity_json_object)
    {
      description: activity_json_object[:description],
      name: activity_json_object[:name],
      notes: activity_json_object[:notes],
      project_id: activity_json_object[:project_id],
      related: activity_json_object[:related],
      theme_id: activity_json_object[:theme_id],
      thumbnail_url: activity_json_object[:thumbnail_url],
      external_report_url: activity_json_object[:external_report_url],
      student_report_enabled: activity_json_object[:student_report_enabled],
      time_to_complete: activity_json_object[:time_to_complete],
      layout: activity_json_object[:layout],
      editor_mode: activity_json_object[:editor_mode]
    }

  end

  def self.import(activity_json_object,new_owner,imported_activity_url=nil,interactives_cache=nil)
    author_user = activity_json_object[:user_email] ? User.find_by_email(activity_json_object[:user_email]) : nil
    import_activity = LightweightActivity.new(self.extact_from_hash(activity_json_object))
    import_activity.theme = Theme.find_by_name(activity_json_object[:theme_name]) if activity_json_object[:theme_name]
    import_activity.imported_activity_url = imported_activity_url
    import_activity.is_official = activity_json_object[:is_official]
    interactives_cache = InteractivesCache.new if interactives_cache.nil?
    LightweightActivity.transaction do
      import_activity.save!(validate: false)
      # Clarify name
      import_activity.name = import_activity.name
      # assign user specified in the json if exist else the importer becomes the author
      import_activity.user = author_user || new_owner
      import_activity.user.is_author = true
      import_activity.user.save!
      activity_json_object[:pages].each do |p|
        import_page = InteractivePage.import(p, interactives_cache)
        import_page.lightweight_activity = import_activity
        import_page.set_list_position(p[:position])
        import_page.save!(validate: false)
      end
      import_activity.fix_page_positions
    end
    import_activity
  end

  # TODO: Include acts_as_list? @pjmorse would hate that.
  def position(seq)
    seq.activities.each_with_index do |a,i|
      return i+1 if a.id == self.id
    end
    raise "Activity #{id} is not part of Sequence #{seq.id}"
  end

  def serialize_for_portal(host)
    local_url = "#{host}#{Rails.application.routes.url_helpers.activity_path(self)}"
    author_url = "#{local_url}/edit"
    print_url = "#{local_url}/print_blank"
    data = {
      "source_type" => "LARA",
      "type" => "Activity",
      "name" => self.name,
      # Description is not used by new Portal anymore. However, we still need to send it to support older Portal instances.
      # Otherwise, the old Portal code would reset its description copy each time the activity was published.
      # When all Portals are upgraded to v1.31 we can stop sending this property.
      "description" => self.description,
      "url" => local_url,
      "create_url" => local_url,
      "author_url" => author_url,
      "print_url"  => print_url,
      "external_report_url"  => external_report_url,
      "student_report_enabled"  => student_report_enabled,
      "thumbnail_url" => thumbnail_url,
      "author_email" => self.user.email,
      "is_locked" => self.is_locked
    }

    pages = []
    visible_pages_with_embeddables.each do |page|
      page_url = "#{host}#{Rails.application.routes.url_helpers.page_path(page)}"
      elements = []
      page.reportable_items.each do |embeddable|
        if embeddable.respond_to?(:portal_hash)
          elements.push(embeddable.portal_hash)
        end
        # Otherwise we don't support this embeddable type right now.
      end
      pages.push({
                   "name" => page.name,
                   "url" => page_url,
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

  def self.search(query)
    where("name LIKE ?", "%#{query}%")
  end

  def glossary
    return Glossary.new
  end
end
