class AddActivityPlayerOnlyOptionToLightweightActivityAndSequence < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :activity_player_only, :boolean
    add_column :sequences, :activity_player_only, :boolean
  end
end
