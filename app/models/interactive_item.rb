module Lightweight
  class InteractiveItem < ActiveRecord::Base
    attr_accessible :interactive, :interactive_page, :position

    belongs_to :interactive_page
    belongs_to :interactive, :polymorphic => true
  end
end
