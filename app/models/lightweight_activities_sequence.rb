class LightweightActivitiesSequence < ApplicationRecord
  belongs_to :lightweight_activity
  belongs_to :sequence

  acts_as_list scope: :sequence
end
