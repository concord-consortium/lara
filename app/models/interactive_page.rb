class InteractivePage < ActiveRecord::Base
  attr_accessible :lightweight_activity, :name, :position, :layout, :sidebar, :show_header,
                  :show_sidebar, :show_interactive, :show_info_assessment, :toggle_info_assessment,
                  :embeddable_display_mode, :sidebar_title, :is_hidden, :additional_sections, :is_completion

  serialize :additional_sections

  belongs_to :lightweight_activity, :class_name => 'LightweightActivity', :touch => true,
    :inverse_of => :pages

  acts_as_list :scope => :lightweight_activity

  LAYOUT_OPTIONS = [{ :name => 'Full Width',               :class_val => 'l-full-width' },
                    { :name => '60-40',                    :class_val => 'l-6040' },
                    { :name => '70-30',                    :class_val => 'l-7030' },
                    { :name => '60-40 (interactive left)', :class_val => 'r-4060' },
                    { :name => '70-30 (interactive left)', :class_val => 'r-3070' },
                    { :name => 'Responsive', :class_val => 'l-responsive' }]

  EMBEDDABLE_DISPLAY_OPTIONS = ['stacked','carousel']

  HEADER_BLOCK = Section::HEADER_BLOCK
  INTERACTIVE_BOX = Section::INTERACTIVE_BOX

  validates :sidebar_title, presence: true
  validates :layout, :inclusion => { :in => LAYOUT_OPTIONS.map { |l| l[:class_val] } }
  validates :embeddable_display_mode, :inclusion => { :in => EMBEDDABLE_DISPLAY_OPTIONS }

  # Reject invalid HTML inputs
  # See https://www.pivotaltracker.com/story/show/60459320
  validates :sidebar, :html => true

  # PageItem is a join model; if this is deleted, it should go too
  # has_many :page_items, :order => [:old_section, :position], :dependent => :destroy, :include => [:embeddable]

  has_many :sections, order: :position, include: [:page_items]

  # NP: 2021-09-01 TODO: This has-many was incorrectly ordering page_items.
  # I don't think it really matters B/C our sections include the page_items.
  # has_many :page_items, through: :sections, order: "sections.position, position"
  def page_items
    sections.map(&:page_items).flatten
  end

  def toggle_info_assessment
    self[:toggle_info_assessment].nil? ? true : self[:toggle_info_assessment]
  end

  @registered_sections = []
  def self.registered_sections
    @registered_sections
  end
  def self.register_section(s)
    @registered_sections.push(s)
  end

  # Interactive page can register additional page sections:
  #
  #  InteractivePage.register_page_section({name: 'FooBar', dir: 'foo_bar', label: 'Foo Bar'})
  #
  # Each section is required to provide two partials:
  # - #{dir}/_author.html.haml
  # - #{dir}/_runtime.html.haml
  #
  # Note that content of the section is totally flexible.
  # If you want to display some embeddables in section, you can provide 'section' argument to
  # .add_embeddable method and then obtain section embeddables using .section_embeddables method.
  @registered_additional_sections = []
  def self.registered_additional_sections
    @registered_additional_sections
  end

  def self.register_additional_section(s)
    @registered_sections.push(s)
    @registered_additional_sections.push(s)
    # Let client code use .update_attributes methods (and similar) to set show_<section_name>.
    attr_accessible "show_#{s[:name]}"
    # show_<section_name> getter:
    define_method("show_#{s[:name]}") do
      additional_sections && additional_sections[s[:name]]
    end
    # show_<section_name> setter:
    define_method("show_#{s[:name]}=") do |v|
      self.additional_sections ||= {}
      # Handle parameter values from Rails forms.
      if v == "1" || v == 1 || v == true
        additional_sections[s[:name]] = true
      else
        additional_sections.delete(s[:name])
      end
    end
  end

  # The order of these register_ calls matters. It determines the order of the embeddables.
  InteractivePage.register_section({name: HEADER_BLOCK, show_method: 'show_header'})
  InteractivePage.register_section({name: nil, show_method: 'show_info_assessment'})

  # Register additional sections of interactive page.
  # This code could (or should) to some config file or initializer, but as we
  # have only one additional section at the moment, let's keep it here.
  InteractivePage.register_additional_section({name:  CRater::ARG_SECTION_NAME,
                                               dir:   CRater::ARG_SECTION_DIR,
                                               label: CRater::ARG_SECTION_LABEL,
                                               show_method: 'show_' + CRater::ARG_SECTION_NAME})

  InteractivePage.register_section({name: INTERACTIVE_BOX, show_method: 'show_interactive'})

  # This is a sort of polymorphic has_many :through (which is forbidden in AR)
  def embeddables
    page_items.map(&:embeddable)
  end

  def interactives
    embeddables.select{ |e| Embeddable::is_interactive?(e) }
  end

  def interactive_page_items
    page_items.select{ |pi| Embeddable::is_interactive?(pi.embeddable) }
  end

  def section_embeddables(section)
    # For now, we continue to support passing a section name as a string to 
    # this method, but this legacy feature will be removed in the future and 
    # passing the section itself will become the only option.
    if !section.instance_of? Section
      section = sections.find { |s| s.id == section_id }
    end

    if section
      section.page_items.map { |i| i.embeddable }
    else
      []
    end
  end

  def visible_embeddables
    results = []
    sections.each do |s|
      results += section_visible_embeddables(s)
    end
    results
  end

  def visible_interactives
    interactives.select{ |e| !e.is_hidden }
  end

  def section_visible_embeddables(section)
    section_embeddables(section).select{ |e| !e.is_hidden }
  end

  def main_visible_embeddables
    # Visible embeddables that do not have section specified (nil section).
    section_visible_embeddables(Section::DEFAULT_SECTION_TITLE)
  end

  # This function will no longer work. There is no longer a header block 
  # section, and passing a section title to section_embeddables is no 
  # longer supported.
  def header_block_embeddables
    section_embeddables(HEADER_BLOCK)
  end

  # This function will no longer work. There is no longer a header block 
  # section, and passing a section title to section_embeddables is no 
  # longer supported.
  def header_block_visible_embeddables
    section_visible_embeddables(HEADER_BLOCK)
  end

  # This function will no longer work. There is no longer an interactive box 
  # section, and passing a section title to section_embeddables is no 
  # longer supported.
  def interactive_box_embeddables
    section_embeddables(INTERACTIVE_BOX)
  end

  # This function will no longer work. There is no longer an interactive box 
  # section, and passing a section title to section_embeddables is no 
  # longer supported.
  def interactive_box_visible_embeddables
    section_visible_embeddables(INTERACTIVE_BOX)
  end

  def reportable_items
    visible_embeddables.select { |item| item.reportable? }
  end

  # 2021-08-05 NP: Lets continue to add embeddables this way and
  ## look for a section identifier value
  def add_embeddable(embeddable, position = nil, section_identifier = nil, column = PageItem::COLUMN_PRIMARY)

    section_identifier ||= Section::DEFAULT_SECTION_TITLE
    # Local function to test whether section_identifier is a numeric value
    numeric = ->(x) { Float(x) != nil rescue false }

    # look for a section specified by title or ID
    if numeric.call(section_identifier)
      section = sections.find { |s| s.id = section_identifier}
      throw "Cant find section #{section_identifier}" unless section
    else
      section = sections.find { |s| s.title == section_identifier }
      unless section
        section = sections.create(Section::DEFAULT_PARAMS.merge({title: section_identifier}))
        section.move_to_top if section.title == Section::HEADER_BLOCK
      end
    end

    section ||= self.sections.create(Section::DEFAULT_PARAMS)

    page_item = section.page_items.create!(embeddable: embeddable, position: position, column: column)

    if (position)
      page_item.insert_at(position)
    else
      page_item.move_to_bottom
    end
  end

  # 2021-08-05 NP: Add a new section.
  def add_section(position = nil, section_type = nil)
    section = self.sections.create(Section::DEFAULT_PARAMS)
    section.move_to_bottom
  end


  def add_interactive(interactive, position = nil, validate = true)
    self[:show_interactive] = true
    self.save!(validate: validate)
    add_embeddable(interactive, position, INTERACTIVE_BOX)
  end

  def next_visible_page
    lightweight_activity.visible_pages.where('position > ?', position).first
  end

  def prev_visible_page
    lightweight_activity.visible_pages.where('position < ?', position).last
  end

  def first_visible?
    !is_hidden && prev_visible_page == nil
  end

  def last_visible?
    !is_hidden && next_visible_page == nil
  end

  def visible_sections
    return [] unless additional_sections
    self.class.registered_additional_sections.select { |s| additional_sections[s[:name]] }
  end

  def to_hash
    # Intentionally leaving out:
    # - lightweight_activity association will be added there
    # - user will get the new user
    # - Associations will be done later
    {
      name: name,
      position: position,
      layout: layout,
      is_hidden: is_hidden,
      sidebar: sidebar,
      sidebar_title: sidebar_title,
      show_header: show_header,
      show_sidebar: show_sidebar,
      show_interactive: show_interactive,
      show_info_assessment: show_info_assessment,
      toggle_info_assessment: toggle_info_assessment,
      embeddable_display_mode: embeddable_display_mode,
      additional_sections: additional_sections,
      is_completion: is_completion
    }
  end

  def set_list_position(index)
    # Overloads the acts_as_list version
    self.position = index
    self.save!(:validate => false) # This is the part we need to override
  end

  def page_number
    lightweight_activity.visible_page_ids.index(self.id) + 1
  end

  def duplicate(helper=nil)
    helper = LaraDuplicationHelper.new if helper.nil?
    new_page = InteractivePage.new(to_hash)
    new_sections = sections.map { |s| s.duplicate(helper) }

    InteractivePage.transaction do
      new_page.save!(validate: false)
      new_sections.each { |s| s.update_attribute(:interactive_page_id, new_page.id) }
    end
    new_page.reload
  end

  def export
    page_json = self.as_json(only: [:id,
                                    :name,
                                    :position,
                                    :layout,
                                    :is_hidden,
                                    :sidebar,
                                    :sidebar_title,
                                    :show_header,
                                    :show_sidebar,
                                    :show_interactive,
                                    :show_info_assessment,
                                    :toggle_info_assessment,
                                    :embeddable_display_mode,
                                    :additional_sections,
                                    :is_completion])
    page_json[:sections] = []

    sections.each do |section|
      page_json[:sections] << section.export
    end

    page_json
  end

  def self.extract_from_hash(page_json_object)
    #pages = activity_json_object[:pages]
    import_simple_attributes = [
      :name,
      :position,
      :layout,
      :is_hidden,
      :sidebar,
      :sidebar_title,
      :show_header,
      :show_sidebar,
      :show_interactive,
      :show_info_assessment,
      :toggle_info_assessment,
      :embeddable_display_mode,
      :is_completion
    ]

    attributes = {}
    import_simple_attributes.each do |key|
      attributes[key] = page_json_object[key] if page_json_object.has_key?(key)
    end

    attributes
  end

  def self.import(page_json_object, helper=nil)
    helper = LaraSerializationHelper.new if helper.nil?
    import_page = InteractivePage.new(self.extract_from_hash(page_json_object))

    InteractivePage.transaction do
      import_page.save!(validate: false)

      # import :additional_sections from page_json_object.
      # It will be a hash looking like this {:arg_block => true }
      # but we need string keys, eg: {"arg_block" => true }
      if page_json_object[:additional_sections]
        page_json_object[:additional_sections].each do |k,v|
          import_page.additional_sections ||= {}
          import_page.additional_sections[k.to_s] = v
        end
      end

      # First, import and cache all the embeddables.
      page_json_object[:embeddables].each do |embed_hash|
        embed = helper.import(embed_hash[:embeddable])
        section = embed_hash[:section]
        import_page.add_embeddable(embed, nil, section)
      end
      # Now when all the objects are created, setup references (e.g. question pointing to interactive, or
      # one embeddable pointing to another one).
      page_json_object[:embeddables].each do |embed_hash|
        helper.set_references(embed_hash[:embeddable])
      end
      # For older export files, if page intro exists, add it as a new embeddable in header_block
      import_legacy_intro(import_page, page_json_object[:text])
    end

    import_page
  end

  def self.import_legacy_intro(import_page, intro_text)
    if intro_text
      helper = LaraSerializationHelper.new if helper.nil?
      intro_embeddable_hash = {
                         "content": intro_text,
                         "is_half_width": false,
                         "is_hidden": false,
                         "name": "",
                         "type": "Embeddable::Xhtml"
                        }
      intro_embeddable = helper.import(intro_embeddable_hash)
      import_page.show_header = true
      import_page.add_embeddable(intro_embeddable, 1, HEADER_BLOCK)
    end
  end
end
