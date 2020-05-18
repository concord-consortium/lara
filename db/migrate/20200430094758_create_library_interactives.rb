class CreateLibraryInteractives < ActiveRecord::Migration
  def change
    create_table :library_interactives do |t|
      t.string :name
      t.text :description
      t.text :authoring_guidance
      t.text :base_url
      t.string :thumbnail_url
      t.string :image_url
      t.string :click_to_play_prompt
      t.boolean :click_to_play,                    :default => false
      t.boolean :no_snapshots,                     :default => false
      t.boolean :enable_learner_state,             :default => false
      t.boolean :has_report_url,                   :default => false
      t.boolean :show_delete_data_button,          :default => true
      t.boolean :full_window,                      :default => false
      t.string :aspect_ratio_method,               :default => "DEFAULT"
      t.integer :native_width
      t.integer :native_height

      t.timestamps
    end
  end
end
