class AddThumbnailUrlToSequences < ActiveRecord::Migration[5.1]
  def change
    add_column :sequences, :thumbnail_url, :string
  end
end
