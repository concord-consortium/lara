module Embeddable
  class OpenResponse < ActiveRecord::Base
    self.table_name_prefix = 'embeddable_'
    attr_accessible :name, :prompt
  end
end
