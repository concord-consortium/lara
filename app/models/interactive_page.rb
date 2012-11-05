module Lightweight
  class InteractivePage < ActiveRecord::Base
    attr_accessible :lightweight_activity, :name, :position, :user, :text, :theme, :sidebar

    belongs_to :lightweight_activity, :class_name => 'Lightweight::LightweightActivity'

    has_many :interactive_items, :order => :position

    def interactives
      self.interactive_items.collect{|ii| ii.interactive}
    end

    has_many :page_items, :order => :position
    def embeddables
      self.page_items.collect{|qi| qi.embeddable}
    end

    def add_interactive(interactive, position = nil)
      Lightweight::InteractiveItem.create!(:interactive_page => self, :interactive => interactive, :position => (position || self.interactive_items.size))
    end

    def add_embeddable(embeddable, position = nil)
      Lightweight::PageItem.create!(:interactive_page => self, :embeddable => embeddable, :position => (position || self.page_items.size))
    end
  end
end
