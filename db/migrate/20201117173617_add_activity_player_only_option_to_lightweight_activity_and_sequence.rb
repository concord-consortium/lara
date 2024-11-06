class AddActivityPlayerOnlyOptionToLightweightActivityAndSequence < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :runtime, :string, default: "LARA"
    add_column :sequences, :runtime, :string, default: "LARA"
  end
end
