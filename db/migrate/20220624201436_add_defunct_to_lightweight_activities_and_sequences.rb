class AddDefunctToLightweightActivitiesAndSequences < ActiveRecord::Migration
  def change
    add_column :lightweight_activities, :defunct, :boolean, default: false
    add_column :sequences, :defunct, :boolean, default: false
  end
end
