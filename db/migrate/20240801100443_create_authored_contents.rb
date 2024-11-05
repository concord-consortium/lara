class CreateAuthoredContents < ActiveRecord::Migration[5.1]
  def change
    create_table :authored_contents do |t|
      t.string :content_type
      t.string :url, :null => true

      t.references :user
      t.references :container, polymorphic: true

      t.timestamps
    end
  end
end
