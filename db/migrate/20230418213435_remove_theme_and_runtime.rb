class RemoveThemeAndRuntime < ActiveRecord::Migration
  def up
    remove_index :lightweight_activities, [:theme_id]
    remove_index :sequences, [:theme_id]

    remove_column :lightweight_activities, :runtime
    remove_column :lightweight_activities, :theme_id
    remove_column :sequences, :runtime
    remove_column :sequences, :theme_id
    remove_column :projects, :theme_id

    drop_table :themes
  end

  def down
    create_table :themes do |t|
      t.string :name
      t.text   :footer
      t.string :css_file
      t.boolean :footer_nav, default: false

      t.timestamps
    end

    add_column :lightweight_activities, :runtime, :string, default: "Activity Player"
    add_column :lightweight_activities, :theme_id, :integer, null: true
    add_column :sequences, :runtime, :string, default: "Activity Player"
    add_column :sequences, :theme_id, :integer, null: true
    add_column :projects, :theme_id, :integer, null: true

    add_index "lightweight_activities", ["theme_id"], name: "index_lightweight_activities_on_theme_id"
    add_index "sequences", ["theme_id"], name: "index_sequences_on_theme_id"
    add_index "projects", ["theme_id"], name: "index_projects_on_theme_id"
  end
end
