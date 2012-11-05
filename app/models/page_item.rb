module Lightweight
  class PageItem < ActiveRecord::Base
    attr_accessible :interactive_page, :position, :embeddable

    belongs_to :interactive_page
    belongs_to :embeddable, :polymorphic => true
  end
end
