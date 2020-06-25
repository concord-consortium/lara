class RemoveIntroductionTextFromInteractivePage < ActiveRecord::Migration
  def up
    remove_column :interactive_pages, :text
  end

  def down
    add_column :interactive_pages, :text, :text
  end
end
