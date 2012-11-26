class InteractivePage < ActiveRecord::Base
  attr_accessible :lightweight_activity, :name, :position, :user, :text, :theme, :sidebar, :show_introduction, :show_sidebar, :show_interactive, :show_info_assessment

  belongs_to :lightweight_activity, :class_name => 'LightweightActivity'

  has_many :interactive_items, :order => :position

  def interactives
    self.interactive_items.collect{|ii| ii.interactive}
  end

  has_many :page_items, :order => :position
  def embeddables
    self.page_items.collect{|qi| qi.embeddable}
  end

  def show_interactive=(value)
    if value.to_i != 0
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
end
