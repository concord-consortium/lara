class AddIsHiddenToInteractives < ActiveRecord::Migration
  def change
    add_column :mw_interactives, :is_hidden, :boolean, default: false
    add_column :image_interactives, :is_hidden, :boolean, default: false
    add_column :video_interactives, :is_hidden, :boolean, default: false
  end
end
