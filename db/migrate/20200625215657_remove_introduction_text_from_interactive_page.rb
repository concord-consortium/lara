class RemoveIntroductionTextFromInteractivePage < ActiveRecord::Migration[5.1]
  def up
    remove_column :interactive_pages, :text
    remove_column :interactive_pages, :show_introduction
  end

  def down
    add_column :interactive_pages, :text, :text
    add_column :interactive_pages, :show_introduction, :boolean, default: false
  end
end
