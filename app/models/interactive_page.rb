class InteractivePage < ActiveRecord::Base
  attr_accessible :lightweight_activity, :name, :position, :user, :text, :layout, :sidebar, :show_introduction, :show_sidebar, :show_interactive, :show_info_assessment

  belongs_to :lightweight_activity, :class_name => 'LightweightActivity'

  acts_as_list :scope => :lightweight_activity

  LAYOUT_OPTIONS = [{ :name => 'Full Width', :class_val => 'l-full-width' },
                    { :name => '60-40',      :class_val => 'l-6040' },
                    { :name => '70-30',      :class_val => 'l-7030' }]

  validates :layout, :inclusion => { :in => LAYOUT_OPTIONS.map { |l| l[:class_val] } }

  has_many :interactive_items, :order => :position

  def interactives
    self.interactive_items.collect{|ii| ii.interactive}
  end

  has_many :page_items, :order => :position

  def embeddables
    self.page_items.collect{|qi| qi.embeddable}
  end

  def show_interactive=(value)
    if value.kind_of?(TrueClass)
      self[:show_interactive] = value
    elsif value.to_i != 0
      if self.interactives.length < 1
        interactive = MwInteractive.create!
        self.add_interactive(interactive)
      else
        self[:show_interactive] = true;
      end
    else
      self[:show_interactive] = false;
    end
  end

  def add_interactive(interactive, position = nil)
    self[:show_interactive] = true;
    self.save
    InteractiveItem.create!(:interactive_page => self, :interactive => interactive, :position => (position || self.interactive_items.size))
  end

  def remove_interactives
    self[:show_interactive] = false;
    self.save
    self.interactives.each do |i|
      i.destroy
    end
    self.interactive_items.each do |ii|
      ii.destroy
    end
  end

  def add_embeddable(embeddable, position = nil)
    join = PageItem.create!(:interactive_page => self, :embeddable => embeddable, :position => position)
    unless position
      join.move_to_bottom
    end
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
      sidebar: sidebar,
      show_introduction: show_introduction,
      show_sidebar: show_sidebar,
      show_interactive: show_interactive,
      show_info_assessment: show_info_assessment
    }
  end

  def duplicate
    # Hash of attributes we want to copy
    new_page_hash = self.to_hash
    # New instance with those attributes
    new_page = InteractivePage.new(new_page_hash)
    # Clarify name
    new_page.name = "Copy of #{new_page.name}"
    # User association
    if defined? current_user
      new_page.user = current_user
    end
    # TODO: Association of interactives and embeddables
    return new_page
    # N.B. the duplicate hasn't been saved yet
  end
end
