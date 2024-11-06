class AddManagedInteractives < ActiveRecord::Migration
  def change
    create_table :managed_interactives do |t|
      t.integer :library_interactive_id

      t.string :name
      t.text :url_fragment
      t.text   :authored_state
      t.boolean :is_hidden,                        :default => false

      t.boolean :inherit_aspect_ratio_method,      :default => true
      t.string  :custom_aspect_ratio_method

      t.boolean :inherit_native_width,             :default => true
      t.integer :custom_native_width

      t.boolean :inherit_native_height,            :default => true
      t.integer :custom_native_height

      t.boolean :inherit_click_to_play,            :default => true
      t.boolean :custom_click_to_play,             :default => false

      t.boolean :inherit_full_window,              :default => true
      t.boolean :custom_full_window,               :default => false

      t.boolean :inherit_click_to_play_prompt,     :default => true
      t.string  :custom_click_to_play_prompt

      t.boolean :inherit_image_url,                :default => true
      t.string  :custom_image_url

      t.integer :linked_interactive_id
      t.boolean :is_full_width,                    :default => true
      t.boolean :show_in_featured_question_report, :default => true

      t.timestamps
    end

    add_column :library_interactives, :export_hash, :string
    add_index :library_interactives,  :export_hash, :name => 'library_interactives_export_hash_idx'
  end
end
