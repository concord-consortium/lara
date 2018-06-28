class AddFullWidthToEmbeddables < ActiveRecord::Migration
  def change
    add_column :embeddable_multiple_choices, :is_full_width, :boolean, :default => false
    add_column :embeddable_open_responses, :is_full_width, :boolean, :default => false
    add_column :embeddable_image_questions, :is_full_width, :boolean, :default => false
    add_column :embeddable_labbooks, :is_full_width, :boolean, :default => false
    add_column :embeddable_xhtmls, :is_full_width, :boolean, :default => false

    # Interactives were always full width, so set appropriate default value.
    add_column :mw_interactives, :is_full_width, :boolean, :default => true
    add_column :image_interactives, :is_full_width, :boolean, :default => true
    add_column :video_interactives, :is_full_width, :boolean, :default => true
  end
end
