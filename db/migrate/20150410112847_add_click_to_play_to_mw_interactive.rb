class AddClickToPlayToMwInteractive < ActiveRecord::Migration[5.1]
  def change
    add_column :mw_interactives, :click_to_play, :boolean
    add_column :mw_interactives, :image_url, :string
  end
end
