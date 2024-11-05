class RenameUrlInVideoInteractive < ActiveRecord::Migration[5.1]
  def change
    rename_column :video_interactives, :url, :poster_url
  end
end
