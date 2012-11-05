class AddOfferingsCounts < ActiveRecord::Migration
  def up
    add_column :lightweight_activities, :offerings_count, :integer
    add_column :interactive_pages, :offerings_count, :integer
  end

  def down
    remove_column :lightweight_activities, :offerings_count
    remove_column :interactive_pages, :offerings_count
  end
end
