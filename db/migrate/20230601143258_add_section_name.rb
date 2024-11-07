class AddSectionName < ActiveRecord::Migration[5.1]
  def change
    add_column :sections, :name, :string
  end
end
