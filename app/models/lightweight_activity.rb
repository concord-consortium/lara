class LightweightActivity < ApplicationRecord
  include Publishable # defines methods to publish to portals
  include PublicationStatus # defines publication status scopes and helpers
  include FixedWidthLayout # defines fixed width options
  include Accessible # defines font options

  LAYOUT_MULTI_PAGE = 0
  LAYOUT_SINGLE_PAGE = 1
  LAYOUT_NOTEBOOK = 2
  LAYOUT_OPTIONS = [
    ['Multi-page', LAYOUT_MULTI_PAGE],
    ['Single-page', LAYOUT_SINGLE_PAGE],
    ['Notebook', LAYOUT_NOTEBOOK]
  ]
  # the override uses 0 as no override and then the rest of the layout options as 1-based
  LAYOUT_OVERRIDE_OPTIONS = [
    ['None', 0],
    ['Multi-page', LAYOUT_MULTI_PAGE + 1],
    ['Single-page', LAYOUT_SINGLE_PAGE + 1],
    ['Notebook', LAYOUT_NOTEBOOK + 1]
  ]
  STANDARD_EDITOR_MODE = 0
  ITSI_EDITOR_MODE = 1
  EDITOR_MODE_OPTIONS = [
    ['Standard', STANDARD_EDITOR_MODE]
  ]


  belongs_to :user # Author
  belongs_to :changed_by, class_name: 'User'

  has_many :plugins, as: :plugin_scope, dependent: :destroy
  has_many :pages, -> { order(:position) },
    foreign_key: 'lightweight_activity_id',
    class_name: 'InteractivePage',
    dependent: :destroy,
    inverse_of: :lightweight_activity
  has_many :visible_pages, -> { where(interactive_pages: {is_hidden: false}).order(:position) },
         foreign_key: 'lightweight_activity_id', class_name: 'InteractivePage'

  has_many :lightweight_activities_sequences, dependent: :destroy
  has_many :sequences, through: :lightweight_activities_sequences
  has_many :runs, foreign_key: 'activity_id', dependent: :destroy
  belongs_to :project
  belongs_to :glossary
  belongs_to :rubric

  has_many :imports, as: :import_item

  belongs_to :copied_from_activity, class_name: "LightweightActivity", foreign_key: "copied_from_id"

  # has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

  # validates_length_of :name, :maximum => 50
  validates :description, :related, html: true

  # Just a way of getting self.visible_pages with the embeddables eager-loaded
  def visible_pages_with_embeddables
    InteractivePage
      .includes(sections: {page_items:  :embeddable})
      .where(lightweight_activity_id: self.id, is_hidden: false)
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
      thumbnail_url: thumbnail_url,
      notes: notes,
      layout: layout,
      editor_mode: editor_mode,
      student_report_enabled: student_report_enabled,
      show_submit_button: show_submit_button,
      hide_read_aloud: hide_read_aloud,
      hide_question_numbers: hide_question_numbers,
      save_interactive_state_history: save_interactive_state_history,
      font_size: font_size
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
      new_activity.rubric_id = self.rubric_id
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
                                        :background_image,
                                        :defunct,
                                        :hide_read_aloud,
                                        :hide_question_numbers,
                                        :save_interactive_state_history,
                                        :font_size ])
    activity_json[:version] = 2
    activity_json[:project] = self.project ? self.project.export : nil
    activity_json[:pages] = []
    self.pages.each do |p|
      activity_json[:pages] << p.export
    end
    activity_json[:plugins] = []
    self.plugins.each do |p|
      # only export plugins that have an approved_script
      if p.approved_script
        activity_json[:plugins] << p.export
      end
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
    activity_json[:fixed_width_layout] = self.fixed_width_layout
    return activity_json
  end

  def self.extract_from_hash(activity_json_object)
    {
      description: activity_json_object[:description],
      name: activity_json_object[:name],
      notes: activity_json_object[:notes],
      related: activity_json_object[:related],
      thumbnail_url: activity_json_object[:thumbnail_url],
      student_report_enabled: activity_json_object[:student_report_enabled],
      show_submit_button: activity_json_object[:show_submit_button],
      time_to_complete: activity_json_object[:time_to_complete],
      layout: activity_json_object[:layout],
      editor_mode: activity_json_object[:editor_mode],
      background_image: activity_json_object[:background_image]
    }

  end

  def self.import(activity_json_object,new_owner,imported_activity_url=nil,helper=nil)
    version = activity_json_object[:version] || 1
    author_user = User.find_by_email(activity_json_object[:user_email]) if activity_json_object[:user_email]
    import_activity = LightweightActivity.new(self.extract_from_hash(activity_json_object))
    import_activity.imported_activity_url = imported_activity_url
    import_activity.is_official = activity_json_object[:is_official]
    import_activity.hide_read_aloud = activity_json_object[:hide_read_aloud]
    import_activity.hide_question_numbers = activity_json_object[:hide_question_numbers]
    import_activity.save_interactive_state_history = activity_json_object[:save_interactive_state_history]
    import_activity.font_size = activity_json_object[:font_size]
    import_activity.project = Project.find_or_create(activity_json_object[:project]) if activity_json_object[:project]
    self.link_glossaries_on_import(activity_json_object, import_activity)
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
        import_page = InteractivePage.import(p, helper, version)
        import_page.lightweight_activity = import_activity
        import_page.set_list_position(p[:position])
        import_page.save!(validate: false)
      end
      import_activity.fix_page_positions
    end
    import_activity
  end

  def self.link_glossaries_on_import(activity_json_object, import_activity)
    # this option will be turned on during testing of activity imports during the
    # LARA2 cutover.  It is potentially dangerous as the domain of the glossary
    # url is ignored so it is possible to link to the incorrect glossary
    return unless ENV['ENABLE_DANGEROUS_GLOSSARY_LINKING_ON_IMPORT'] == "true"

    return unless activity_json_object[:plugins]

    glossary_plugin_object = activity_json_object[:plugins].find { |p| p[:approved_script_label] == "glossary" }
    return unless glossary_plugin_object && glossary_plugin_object[:author_data]

    author_data = JSON.parse(glossary_plugin_object[:author_data], symbolize_names: true)
    return unless author_data && author_data[:s3Url]

    # this purposefully ignores the domain of the original glossary url
    # so that we can import between domains when doing the LARA 2 cutover
    matches = author_data[:s3Url].match /\/api\/v1\/glossaries\/(\d+)/
    return unless matches && matches[1]

    import_activity.glossary = Glossary.find_by_id(matches[1])
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

    rubric_url = ""
    rubric_doc_url = ""
    if self.rubric != nil
      rubric_doc_url = self.rubric.doc_url
      if self.rubric.authored_content != nil
        rubric_url = self.rubric.authored_content.url
      end
    end

    data = {
      "type" => "Activity",
      "name" => self.name,
      "author_url" => "#{local_url}/edit",
      "print_url"  => "#{local_url}/print_blank",
      "student_report_enabled"  => student_report_enabled,
      "show_submit_button"  => show_submit_button,
      "thumbnail_url" => thumbnail_url,
      "is_locked" => self.is_locked,
      "url" => activity_player_url(host),
      "tool_id" => "https://activity-player.concord.org",
      "append_auth_token" => true,
      "rubric_url" => rubric_url,
      "rubric_doc_url" => rubric_doc_url,
    }

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
      page_url = activity_player_url(host, page: page, preview: true)
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
      url: activity_url,
      migration_status: migration_status,
      preview_url: activity_player_url(host, preview: true)
    }

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
        children: questions,
        preview_url: activity_player_url(host, page: page, preview: true)
      }

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

  def self.search(query, _user)  # user not used
    if query.to_s =~ /^\d+$/ && query.to_i > 0
      where("name LIKE ? OR id = ?", "%#{query}%", query.to_i)
    else
      where("name LIKE ?", "%#{query}%")
    end
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
