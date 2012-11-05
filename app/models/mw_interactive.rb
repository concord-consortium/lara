module Lightweight
  class MwInteractive < ActiveRecord::Base
    attr_accessible :name, :url, :user, :width

    validates_numericality_of :width, :less_than_or_equal_to => 100, :greater_than => 5

    has_one :interactive_item, :as => :interactive
    has_one :interactive_page, :through => :interactive_item
  end
end
