class CRater::Settings < ActiveRecord::Base
  belongs_to :provider, polymorphic: true
  belongs_to :score_mapping
  attr_accessible :item_id, :score_mapping_id
end
