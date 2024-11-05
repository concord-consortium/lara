class UpdateIsHiddenInPage < ActiveRecord::Migration[5.1]
  def up
    InteractivePage.update_all({:is_hidden => false}, {:is_hidden => nil})
    change_column :interactive_pages, :is_hidden, :boolean, :default => false, :null => false
  end

  def down
    change_column :interactive_pages, :is_hidden, :boolean, :default => false, :null => true
  end
end
