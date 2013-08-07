class AddShowLightboxToImageInteractive < ActiveRecord::Migration
  def change
    add_column :image_interactives, :show_lightbox, :boolean, :default => true
  end
end
