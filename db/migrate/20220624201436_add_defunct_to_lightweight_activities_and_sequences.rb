class AddDefunctToLightweightActivitiesAndSequences < ActiveRecord::Migration[5.1]
  def change
    add_column :lightweight_activities, :defunct, :boolean, default: false
    add_column :sequences, :defunct, :boolean, default: false
  end
end
