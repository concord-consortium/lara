class AddShowLightboxToImageInteractive < ActiveRecord::Migration[5.1]
  def change
    add_column :image_interactives, :show_lightbox, :boolean, :default => true
  end
end
