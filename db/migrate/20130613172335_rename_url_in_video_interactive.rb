class RenameUrlInVideoInteractive < ActiveRecord::Migration
  def change
    rename_column :video_interactives, :url, :poster_url
  end
end
