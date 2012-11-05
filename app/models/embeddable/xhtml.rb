module Embeddable
  class Xhtml < ActiveRecord::Base
    self.table_name_prefix = 'embeddable_'
    attr_accessible :name, :content
  end
end
