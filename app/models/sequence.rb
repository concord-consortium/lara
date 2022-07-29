class Sequence < ActiveRecord::Base

  attr_accessible :description, :title, :theme_id, :project_id, :defunct, 
    :user_id, :logo, :display_title, :thumbnail_url, :abstract, :publication_hash,
    :runtime, :project, :background_image

  include Publishable # defines methods to publish to portals
  include PublicationStatus # defines publication status scopes and helpers
  include FixedWidthLayout # defines fixed width options
  has_many :lightweight_activities_sequences, :order => :position, :dependent => :destroy
  has_many :lightweight_activities, :through => :lightweight_activities_sequences, :order => :position
  belongs_to :user
  belongs_to :theme
  belongs_to :project

  has_many :imports, as: :import_item

  # scope :newest, order("updated_at DESC")
  # TODO: Sequences and possibly activities will eventually belong to projects e.g. HAS, SFF

  def name
    # activities have names, so to be consistent ...
    self.title
  end
  def time_to_complete
    time = 0
    lightweight_activities.map { |a| time = time + (a.time_to_complete ? a.time_to_complete : 0) }
    time
  end

  def activities
    lightweight_activities
  end

  def next_activity(activity)
    # Given an activity, return the next one in the sequence
    get_neighbor(activity, false)
  end

  def previous_activity(activity)
    # Given an activity, return the previous one in the sequence
    get_neighbor(activity, true)
  end

  def to_hash
    # We're intentionally not copying:
    # - is_official (defaults to false, can be changed)
    # - user_id (the copying user should be the owner)
    {
      title: title,
      description: description,
      publication_status: publication_status,
      abstract: abstract,
      theme_id: theme_id,
      project: project,
      logo: logo,
      display_title: display_title,
      thumbnail_url: thumbnail_url,
      runtime: runtime
    }
  end

  def fix_activity_position(positions)
    # This is not necessary, as 'lightweight_activities_sequences' is ordered by
    # position, so we already copied and add activities in a right order. However
    # copying exact position values seems to be safer and more resistant
    # to possible errors in the future.
    self.lightweight_activities_sequences.each_with_index do |sa, i|
      sa.position = positions[i]
      sa.save!
    end
    self.save!
  end

  def duplicate(new_owner)
    helper = LaraDuplicationHelper.new
    new_sequence = Sequence.new(self.to_hash)
    Sequence.transaction do
      new_sequence.title = "Copy of #{self.name}"
      new_sequence.user = new_owner
      positions = []
      lightweight_activities_sequences.each do |sa|
        new_a = sa.lightweight_activity.duplicate(new_owner, helper)
        new_a.name = new_a.name.sub('Copy of ', '')
        new_a.save!
        new_sequence.activities << new_a
        positions << sa.position
      end
      new_sequence.save!
      new_sequence.fix_activity_position(positions)
    end
    new_sequence
  end

  def export(host)
    sequence_json = self.as_json(only: [:title,
                                        :description,
                                        :abstract,
                                        :theme_id,
                                        :logo,
                                        :display_title,
                                        :thumbnail_url,
                                        :runtime,
                                        :background_image,
                                        :defunct
    ])
    sequence_json[:project] = self.project ? self.project.export : nil
    sequence_json[:activities] = []
    self.lightweight_activities.each_with_index do |a,i|
      activity_hash = a.export(host)
      activity_hash[:position] = i+1
      sequence_json[:activities] << activity_hash
    end
    sequence_json[:type] = "Sequence"
    sequence_json[:export_site] = "Lightweight Activities Runtime and Authoring"
    if self.runtime == "Activity Player"
      sequence_json[:fixed_width_layout] = self.fixed_width_layout
    end
    return sequence_json.to_json
  end

  def serialize_for_portal_basic(host)
    local_url = "#{host}#{Rails.application.routes.url_helpers.sequence_path(self)}"
    api_url = "#{host}#{Rails.application.routes.url_helpers.api_v1_sequence_path(self)}.json"
    ap_url = ENV["ACTIVITY_PLAYER_URL"] + "?sequence=" + api_url

    if self.runtime == "Activity Player"
      run_url = ap_url
      source_type = "Activity Player"
      append_auth_token = true
      tool_id = ENV["ACTIVITY_PLAYER_URL"]
    else
      run_url = local_url
      source_type = "LARA"
      append_auth_token = false
      tool_id = ""
    end

    {
      'source_type' => source_type,
      'type' => 'Sequence',
      'name' => self.title,
      "url" => run_url,
      "author_url" => "#{local_url}/edit",
      "print_url"  => "#{local_url}/print_blank",
      "thumbnail_url" => thumbnail_url,
      # These are specific to the Activity Player publish
      "tool_id" => tool_id,
      "append_auth_token" => append_auth_token
    }
  end

  def serialize_for_portal(host)
    data = serialize_for_portal_basic(host)
    data["create_url"] = data["url"]
    data["author_email"] = self.user.email
    # Description is not used by new Portal anymore. However, we still need to send it to support older Portal instances.
    # Otherwise, the old Portal code would reset its description copy each time the sequence was published.
    # When all Portals are upgraded to v1.31 we can stop sending this property.
    data["description"] = self.description
    # Abstract is not used by new Portal anymore. However, we still need to send it to support older Portal instances.
    # Otherwise, the old Portal code would reset its abstract copy each time the sequence was published.
    # When all Portals are upgraded to v1.31 we can stop sending this property.

    data["abstract"] = self.abstract
    data["activities"] = self.activities.map { |a| a.serialize_for_portal(host) }
    data
  end

  def serialize_for_report_service(host)
    local_url = "#{host}#{Rails.application.routes.url_helpers.sequence_path(self)}"
    data = {
      id: 'sequence_' + self.id.to_s,
      type: 'sequence',
      name: self.title,
      url: local_url
    }
    if self.runtime == "Activity Player"
      data[:preview_url] = self.activity_player_sequence_url(host, preview: true)
    end

    # FIXME: the urls and preview_urls in these activities do not include the
    # the sequence, so links in the report to the activities or activity pages
    # will not show the activity or page in the context of a sequence
    # see https://www.pivotaltracker.com/story/show/177122631
    migration_status = "unknown"
    data[:children] = self.activities.map { |a| 
      if a.migration_status != "migrated"
        migration_status = "not_migrated"
      end
      a.serialize_for_report_service(host)
    }
    if data[:children].count > 0 && migration_status == "unknown"
      migration_status = "migrated"
    end
    data[:migration_status] = migration_status
    data
  end

  def activity_player_sequence_url(host, preview: false, mode: nil, activity: nil)
    sequence_api_url = "#{host}#{Rails.application.routes.url_helpers.api_v1_sequence_path(self)}.json"
    uri = URI.parse(ENV["ACTIVITY_PLAYER_URL"])
    query = Rack::Utils.parse_query(uri.query)
    query["sequence"] = sequence_api_url
    if preview
      query["preview"] = nil # adds 'preview' to query string as a valueless param
    end
    if mode
      query["mode"] = mode
    end
    if activity
      query["sequenceActivity"] = activity
    end
    uri.query = Rack::Utils.build_query(query)
    return uri.to_s
  end

  def self.extract_from_hash(sequence_json_object)
    {
      abstract: sequence_json_object[:abstract],
      description: sequence_json_object[:description],
      display_title: sequence_json_object[:display_title],
      logo: sequence_json_object[:logo],
      theme_id: sequence_json_object[:theme_id],
      thumbnail_url: sequence_json_object[:thumbnail_url],
      title: sequence_json_object[:title],
      runtime: sequence_json_object[:runtime],
      background_image: sequence_json_object[:background_image]
    }

  end

  def self.import(sequence_json_object, new_owner, imported_activity_url=nil)
    helper = LaraSerializationHelper.new
    import_sequence = Sequence.new(self.extract_from_hash(sequence_json_object))
    import_sequence.runtime = sequence_json_object[:runtime]
    import_sequence.project = Project.find_or_create(sequence_json_object[:project]) if sequence_json_object[:project]
    Sequence.transaction do
      import_sequence.title = import_sequence.title
      import_sequence.imported_activity_url = imported_activity_url
      import_sequence.user = new_owner
      positions = []
      sequence_json_object[:activities].each do |sa|
        import_a = LightweightActivity.import(sa, new_owner, nil, helper)
        import_a.save!
        import_sequence.activities << import_a
        positions << sa[:position]
      end
      import_sequence.save!
      import_sequence.fix_activity_position(positions)
    end
    return import_sequence
  end

  def self.search(query, _user)  # user not used
    where("title LIKE ?", "%#{query}%")
  end

  private
  def get_neighbor(activity, higher)
    join = lightweight_activities_sequences.find_by_lightweight_activity_id(activity.id)
    if join.blank? || (join.first? && higher) || (join.last? && !higher)
      return nil
    elsif join && higher
      return join.higher_item.lightweight_activity
    elsif join && !higher
      return join.lower_item.lightweight_activity
    else
      return nil
    end
  end
end
