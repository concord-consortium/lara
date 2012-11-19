class InteractivePage < ActiveRecord::Base
  include Workflow

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
    if (value.to_i != 0)
      interactive = MwInteractive.create!
      add_interactive!(interactive)
    else
      remove_interactive!
    end
  end

  def add_interactive(interactive, position = nil)
    self[:show_interactive] = true;
    self.save
    InteractiveItem.create!(:interactive_page => self, :interactive => interactive, :position => (position || self.interactive_items.size))
  end

  def remove_interactive
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
    PageItem.create!(:interactive_page => self, :embeddable => embeddable, :position => (position || self.page_items.size))
  end

  workflow do
    state :no_interactive do
      event :add_interactive, :transitions_to => :has_interactive
    end

    state :has_interactive do
      event :remove_interactive, :transitions_to => :no_interactive
    end
  end
end
