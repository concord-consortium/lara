class CRater::Settings < ActiveRecord::Base
  belongs_to :provider, polymorphic: true
  belongs_to :score_mapping
  attr_accessible :item_id
end
