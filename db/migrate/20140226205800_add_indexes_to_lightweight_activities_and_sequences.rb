class AddIndexesToLightweightActivitiesAndSequences < ActiveRecord::Migration
  def change
    add_index "lightweight_activities", ["updated_at"], name: "lightweight_activities_updated_at_idx"
    add_index "sequences", ["updated_at"], name: "sequences_updated_at_idx"
  end
end
