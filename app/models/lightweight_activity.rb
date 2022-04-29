class LightweightActivity < ActiveRecord::Base
  include Publishable # defines methods to publish to portals
  include PublicationStatus # defines publication status scopes and helpers
  include FixedWidthLayout # defines fixed width options

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
                  :student_report_enabled, :show_submit_button, :runtime, :project, :background_image,
                  :glossary_id

  belongs_to :user # Author
  belongs_to :changed_by, :class_name => 'User'

  has_many :plugins, as: :plugin_scope, :dependent => :destroy
  has_many :pages,
    :foreign_key => 'lightweight_activity_id',
    :class_name => 'InteractivePage',
    :order => :position,
    :dependent => :destroy,
    :inverse_of => :lightweight_activity
  has_many :visible_pages, :foreign_key => 'lightweight_activity_id', :class_name => 'InteractivePage', :order => :position,
             :conditions => {interactive_pages: {is_hidden: false}}

  has_many :lightweight_activities_sequences, :dependent => :destroy
  has_many :sequences, :through => :lightweight_activities_sequences
  has_many :runs, :foreign_key => 'activity_id', :dependent => :destroy
  belongs_to :theme
  belongs_to :project
  belongs_to :glossary

  has_many :imports, as: :import_item

  belongs_to :copied_from_activity, :class_name => "LightweightActivity", :foreign_key => "copied_from_id"

  # has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

  # validates_length_of :name, :maximum => 50
  validates :description, :related, :html => true

  # Just a way of getting self.visible_pages with the embeddables eager-loaded
  def visible_pages_with_embeddables
    InteractivePage
      .includes(sections: {page_items:  :embeddable})
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
    # - user_id (the copying user should be the owner)
    # - Pages (associations will be done differently)
    {
      name: name,
      related: related,
      publication_status: publication_status,
      description: description,
      time_to_complete: time_to_complete,
      project: project,
      theme_id: theme_id,
      thumbnail_url: thumbnail_url,
      notes: notes,
      layout: layout,
      editor_mode: editor_mode,
      student_report_enabled: student_report_enabled,
      show_submit_button: show_submit_button,
      runtime: runtime
    }
  end

  def duplicate(new_owner, helper=nil)
    helper = LaraDuplicationHelper.new if helper.nil?
    new_activity = LightweightActivity.new(self.to_hash)
    LightweightActivity.transaction do
      new_activity.save!(validate: false)
      # Clarify name
      new_activity.name = "Copy of #{new_activity.name}"
      new_activity.user = new_owner
      new_activity.copied_from_id = self.id
      self.pages.each do |p|
        new_page = p.duplicate(helper)
        new_page.lightweight_activity = new_activity
        new_page.set_list_position(p.position)
        new_page.save!(validate: false)
      end
      new_activity.fix_page_positions
      self.plugins.each do |p|
        new_activity.plugins.push(p.duplicate)
      end
      new_activity.glossary_id = self.glossary_id
    end
    new_activity
  end

  def fake_glossary_plugin_id
    self.glossary_id * 1_000_000_000 + self.id
  end

  def export(host)
    activity_json = self.as_json(only: [:id,
                                        :name,
                                        :related,
                                        :description,
                                        :time_to_complete,
                                        :thumbnail_url,
                                        :notes,
                                        :layout,
                                        :editor_mode,
                                        :student_report_enabled,
                                        :show_submit_button,
                                        :runtime,
                                        :background_image ])
    activity_json[:version] = 2
    activity_json[:theme_name] = self.theme ? self.theme.name : nil
    activity_json[:project] = self.project ? self.project.export : nil
    activity_json[:pages] = []
    self.pages.each do |p|
      activity_json[:pages] << p.export
    end
    activity_json[:plugins] = []
    self.plugins.each do |p|
      activity_json[:plugins] << p.export
    end

    # if the activity has a glossary model assiged to it, add the fake glossary plugin to the list of plugins
    # replacing any existing glossary plugins and using the existing glossary plugin's approved script
    if self.glossary_id && approved_glossary_script = Glossary.get_glossary_approved_script()
      # remove any existing glossary script
      activity_json[:plugins].delete_if { |plugin| plugin[:component_label] == "glossary" }

      fake_glossary_plugin = {
        id: fake_glossary_plugin_id(),
        description: nil,
        author_data: JSON.generate({
          version:"1.0",
          glossaryResourceId: "this-is-a-fake-glossary-resource-id",
          s3Url: Rails.application.routes.url_helpers.api_v1_glossary_url(self.glossary_id, host: host, json_only: true)
        }),
        approved_script_label: "glossary",
        component_label: "glossary",
        approved_script: approved_glossary_script.to_hash
      }
      activity_json[:plugins] << fake_glossary_plugin
    end

    activity_json[:type] = "LightweightActivity"
    activity_json[:export_site] = "Lightweight Activities Runtime and Authoring"
    if self.runtime == "Activity Player"
      activity_json[:fixed_width_layout] = self.fixed_width_layout
    end
    return activity_json
  end

  def self.extract_from_hash(activity_json_object)
    {
      description: activity_json_object[:description],
      name: activity_json_object[:name],
      notes: activity_json_object[:notes],
      related: activity_json_object[:related],
      theme_id: activity_json_object[:theme_id],
      thumbnail_url: activity_json_object[:thumbnail_url],
      student_report_enabled: activity_json_object[:student_report_enabled],
      show_submit_button: activity_json_object[:show_submit_button],
      time_to_complete: activity_json_object[:time_to_complete],
      layout: activity_json_object[:layout],
      editor_mode: activity_json_object[:editor_mode],
      runtime: activity_json_object[:runtime],
      background_image: activity_json_object[:background_image]
    }

  end

  def self.import(activity_json_object,new_owner,imported_activity_url=nil,helper=nil)
    author_user = User.find_by_email(activity_json_object[:user_email]) if activity_json_object[:user_email]
    import_activity = LightweightActivity.new(self.extract_from_hash(activity_json_object))
    import_activity.theme = Theme.find_by_name(activity_json_object[:theme_name]) if activity_json_object[:theme_name]
    import_activity.imported_activity_url = imported_activity_url
    import_activity.is_official = activity_json_object[:is_official]
    import_activity.runtime = activity_json_object[:runtime]
    import_activity.project = Project.find_or_create(activity_json_object[:project]) if activity_json_object[:project]
    helper = LaraSerializationHelper.new if helper.nil?
    LightweightActivity.transaction do
      import_activity.save!(validate: false)
      # Clarify name
      import_activity.name = import_activity.name
      # assign user specified in the json if exist else the importer becomes the author
      import_activity.user = author_user || new_owner
      import_activity.user.is_author = true
      import_activity.user.save!
      activity_json_object[:pages].each do |p|
        import_page = InteractivePage.import(p, helper)
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

  def serialize_for_portal_basic(host)
    local_url = "#{host}#{Rails.application.routes.url_helpers.activity_path(self)}"

    data = {
      "type" => "Activity",
      "name" => self.name,
      "author_url" => "#{local_url}/edit",
      "print_url"  => "#{local_url}/print_blank",
      "student_report_enabled"  => student_report_enabled,
      "show_submit_button"  => show_submit_button,
      "thumbnail_url" => thumbnail_url,
      "is_locked" => self.is_locked
    }

    if self.runtime == "Activity Player"
      data["url"] = activity_player_url(host)
      data["tool_id"] = "https://activity-player.concord.org"
      data["append_auth_token"] = true
    else
      data["url"] = local_url
    end

    data
  end

  def serialize_for_portal(host)
    data = serialize_for_portal_basic(host)
    data["source_type"] = "LARA"
    data["create_url"] = data["url"]
    data["author_email"] = user.email
    # Description is not used by new Portal anymore. However, we still need to send it to support older Portal instances.
    # Otherwise, the old Portal code would reset its description copy each time the activity was published.
    # When all Portals are upgraded to v1.31 we can stop sending this property.
    data["description"] = self.description

    pages = []
    visible_pages_with_embeddables.each do |page|
      if self.runtime == "Activity Player"
        page_url = activity_player_url(host, page: page, preview: true)
      else
        page_url = "#{host}#{Rails.application.routes.url_helpers.page_path(page)}"
      end
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

  def serialize_for_report_service(host)
    activity_url = "#{host}#{Rails.application.routes.url_helpers.activity_path(self)}"
    data = {
      id: "activity_" + self.id.to_s,
      type: "activity",
      name: self.name,
      url: activity_url
    }
    if self.runtime == "Activity Player"
      data[:preview_url] = activity_player_url(host, preview: true)
    end

    pages = []
    visible_pages_with_embeddables.each do |page|
      questions = []
      page.reportable_items.each do |embeddable|
        questions.push(embeddable.report_service_hash) if embeddable.respond_to?(:report_service_hash)
        # Otherwise we don't support this embeddable type right now.
      end
      page_url = "#{host}#{Rails.application.routes.url_helpers.page_path(page)}"
      page_data = {
        id: "page_" + page.id.to_s,
        type: "page",
        name: page.name,
        url: page_url,
        children: questions
      }
      if self.runtime == "Activity Player"
        page_data[:preview_url] = activity_player_url(host, page: page, preview: true)
      end

      pages.push(page_data)
    end

    # Fake section to satisfy current report service requirement. Hopefully, it won't be necessary soon.
    section = {
      # There's only one, artificial section per activity, so it's fine to reuse activity ID.
      id: "section_" + self.id.to_s,
      type: "section",
      name: "#{self.name} Section",
      url: activity_url,
      children: pages
    }

    # NOTE: there is no Activity Player runtime component for a section so the section
    # doesn't have a preview_url

    data[:children] = [ section ]
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

  def activity_player_url(host, page: nil, preview: false, mode: nil)
    api_url = "#{host}#{Rails.application.routes.url_helpers.api_v1_activity_path(self)}.json"
    uri = URI.parse(ENV["ACTIVITY_PLAYER_URL"])
    query = Rack::Utils.parse_query(uri.query)
    query["activity"] = api_url
    if page != nil
      query["page"] = "page_#{page.id}"
    end
    if preview
      query["preview"] = nil # adds 'preview' to query string as a valueless param
    end
    if mode
      query["mode"] = mode
    end
    uri.query = Rack::Utils.build_query(query)
    return uri.to_s
  end
end
