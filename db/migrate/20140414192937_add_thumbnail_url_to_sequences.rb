class AddThumbnailUrlToSequences < ActiveRecord::Migration
  def change
    add_column :sequences, :thumbnail_url, :string
  end
end
