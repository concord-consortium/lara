class AddSectionName < ActiveRecord::Migration
  def change
    add_column :sections, :name, :string
  end
end
