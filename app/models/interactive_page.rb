class InteractivePage < ActiveRecord::Base
  attr_accessible :lightweight_activity, :name, :position, :text, :layout, :sidebar, :show_introduction, :show_sidebar,
                  :show_interactive, :show_info_assessment, :embeddable_display_mode, :sidebar_title, :is_hidden,
                  :additional_sections

  serialize :additional_sections

  belongs_to :lightweight_activity, :class_name => 'LightweightActivity', :touch => true

  acts_as_list :scope => :lightweight_activity

  LAYOUT_OPTIONS = [{ :name => 'Full Width',               :class_val => 'l-full-width' },
                    { :name => '60-40',                    :class_val => 'l-6040' },
                    { :name => '70-30',                    :class_val => 'l-7030' },
                    { :name => '60-40 (interactive left)', :class_val => 'r-4060' },
                    { :name => '70-30 (interactive left)', :class_val => 'r-3070' }]

  EMBEDDABLE_DISPLAY_OPTIONS = ['stacked','carousel']

  INTERACTIVE_TYPES = [{ :name => 'Image',  :class_name => 'ImageInteractive' },
                       { :name => 'Iframe', :class_name => 'MwInteractive' },
                       { :name => 'Video',  :class_name => 'VideoInteractive' }]

  validates :sidebar_title, presence: true
  validates :layout, :inclusion => { :in => LAYOUT_OPTIONS.map { |l| l[:class_val] } }
  validates :embeddable_display_mode, :inclusion => { :in => EMBEDDABLE_DISPLAY_OPTIONS }

  # Reject invalid HTML inputs
  # See https://www.pivotaltracker.com/story/show/60459320
  validates :text, :sidebar, :html => true

  # InteractiveItem is a join model; if this is deleted, it should go too
  has_many :interactive_items, :order => :position, :dependent => :destroy, :include => [:interactive]

  # Like InteractiveItems, PageItems are join models, so they should not
  # survive the deletion of associated instances of InteractivePage.
  has_many :page_items, :order => [:section, :position], :dependent => :destroy, :include => [:embeddable]

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

  # Register additional sections of interactive page.
  # This code could (or should) to some config file or initializer, but as we
  # have only one additional section at the moment, let's keep it here.
  InteractivePage.register_additional_section({name:  CRater::ARG_SECTION_NAME,
                                               dir:   CRater::ARG_SECTION_DIR,
                                               label: CRater::ARG_SECTION_LABEL})

  # This is a sort of polymorphic has_many :through.
  def interactives
    self.interactive_items.collect{|ii| ii.interactive}
  end

  def visible_interactives
    interactives.select { |i| !i.is_hidden }
  end

  # can this page display multiple interactives?
  # depending on the activity layout, possibly.
  # For now, only with single-page louts.
  def show_multiple_interactives?
    lightweight_activity &&
      lightweight_activity.layout == LightweightActivity::LAYOUT_SINGLE_PAGE
  end


  # This is a sort of polymorphic has_many :through.
  def embeddables
    self.page_items.collect{ |qi| qi.embeddable }
  end

  def section_embeddables(section)
    self.page_items.where(section: section).collect{ |qi| qi.embeddable }
  end

  def main_embeddables
    # Embeddables that do not have section specified (nil section).
    section_embeddables(nil)
  end

  def visible_embeddables
    self.page_items.collect{ |qi| qi.embeddable }.select{ |e| !e.is_hidden }
  end

  def section_visible_embeddables(section)
    self.page_items.where(section: section).collect{ |qi| qi.embeddable }.select{ |e| !e.is_hidden }
  end

  def main_visible_embeddables
    # Visible embeddables that do not have section specified (nil section).
    section_visible_embeddables(nil)
  end

  def add_interactive(interactive, position = nil, validate = true)
    self[:show_interactive] = true;
    self.save!(validate: validate)
    InteractiveItem.create!(:interactive_page => self, :interactive => interactive, :position => (position || self.interactive_items.size))
  end

  def remove_interactives
    self[:show_interactive] = false;
    self.save!
    self.interactives.each do |i|
      i.destroy
    end
    self.interactive_items.each do |ii|
      ii.destroy
    end
  end

  def add_embeddable(embeddable, position = nil, section = nil)
    join = PageItem.create!(:interactive_page => self, :embeddable => embeddable,
                            :position => position, :section => section)
    unless position
      join.move_to_bottom
    end
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
      text: text,
      layout: layout,
      is_hidden: is_hidden,
      sidebar: sidebar,
      sidebar_title: sidebar_title,
      show_introduction: show_introduction,
      show_sidebar: show_sidebar,
      show_interactive: show_interactive,
      show_info_assessment: show_info_assessment,
      embeddable_display_mode: embeddable_display_mode,
      additional_sections: additional_sections
    }
  end

  def set_list_position(index)
    # Overloads the acts_as_list version
    self.position = index
    self.save!(:validate => false) # This is the part we need to override
  end

  def duplicate
    new_page = InteractivePage.new(self.to_hash)
    helper = LaraSerializationHelper.new()

    InteractivePage.transaction do
      new_page.save!(validate: false)

      self.interactives.each do |inter|
        copy = inter.duplicate
        new_page.add_interactive(copy, nil, false)
        helper.cache_item_copy(inter,copy)
      end

      self.main_embeddables.each do |embed|
        copy = embed.duplicate
        if embed.respond_to? :interactive=
          unless embed.interactive.nil?
            copy.interactive = helper.lookup_new_item(embed.interactive)
          end
        end
        copy.save!(validate: false)
        if embed.respond_to? :question_tracker and embed.question_tracker
          embed.question_tracker.add_question(copy)
        end
        new_page.add_embeddable(copy)
      end

      self.class.registered_additional_sections.each do |s|
        self.section_embeddables(s[:name]).each do |embed|
          copy = embed.duplicate
          copy.save!(validate: false)
          new_page.add_embeddable(copy,nil,s[:name])
        end
      end
    end
    return new_page.reload
  end

  def export
    helper = LaraSerializationHelper.new
    page_json = self.as_json(only: [:name,
                                    :position,
                                    :text,
                                    :layout,
                                    :is_hidden,
                                    :sidebar,
                                    :sidebar_title,
                                    :show_introduction,
                                    :show_sidebar,
                                    :show_interactive,
                                    :show_info_assessment,
                                    :embeddable_display_mode,
                                    :additional_sections])

    page_json[:interactives] = []
    page_json[:embeddables] = []
    page_json[:sections] = []

    self.interactives.each do |inter|
      interactive_hash = helper.wrap_export(inter)
      page_json[:interactives] << interactive_hash
    end
    self.main_embeddables.each do |embed|
      embeddable_hash = helper.wrap_export(embed)
      page_json[:embeddables] << embeddable_hash
    end
    self.class.registered_additional_sections.each do |s|
      additional_section = {name:s[:name],section_embeddables:[]}
      self.section_embeddables(s[:name]).each do |embed|
        section_embeddable_hash = helper.wrap_export(embed)
        additional_section[:section_embeddables] << section_embeddable_hash
      end
      page_json[:sections] << additional_section
    end

    return page_json
  end

  def self.extact_from_hash(page_json_object)
    #pages = activity_json_object[:pages]
    import_simple_attributes = [
      :name,
      :position,
      :text,
      :layout,
      :is_hidden,
      :sidebar,
      :sidebar_title,
      :show_introduction,
      :show_sidebar,
      :show_interactive,
      :show_info_assessment,
      :embeddable_display_mode
    ]

    attributes = {}
    import_simple_attributes.each do |key|
      attributes[key] = page_json_object[key] if page_json_object.has_key?(key)
    end

    if page_json_object[:additional_sections]
      attributes[:additional_sections] = page_json_object[:additional_sections].as_json
    end
    attributes
  end

  def self.import(page_json_object)
    helper = LaraSerializationHelper.new
    import_page = InteractivePage.new(self.extact_from_hash(page_json_object))
    InteractivePage.transaction do
      import_page.save!(validate: false)
      page_json_object[:interactives].each do |inter|
        import_interactive = helper.wrap_import(inter)
        import_page.add_interactive(import_interactive, nil, false)
      end
      page_json_object[:embeddables].each do |embed|
        import_embeddable = helper.wrap_import(embed)
        import_page.add_embeddable(import_embeddable)
      end
      if page_json_object[:sections]
        page_json_object[:sections].each do |sec|
          sec[:section_embeddables].each do |embed|
            import_embeddable = helper.wrap_import(embed)
            import_page.add_embeddable(import_embeddable,nil,sec[:name])
          end
        end
      end
    end
    return import_page
  end
end
