class PageItem < ActiveRecord::Base
  attr_accessible :interactive_page, :position, :section, :embeddable
  acts_as_list :scope => :interactive_page

  belongs_to :interactive_page
  belongs_to :embeddable, :polymorphic => true
end
