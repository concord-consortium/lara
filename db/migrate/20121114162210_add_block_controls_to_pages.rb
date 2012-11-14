class AddBlockControlsToPages < ActiveRecord::Migration
  def change
    add_column :interactive_pages, :show_introduction, :boolean, :default => false
    add_column :interactive_pages, :show_sidebar, :boolean, :default => false
    add_column :interactive_pages, :show_interactive, :boolean, :default => false
    add_column :interactive_pages, :show_info_assessment, :boolean, :default => false
    InteractivePage.all.each do |page|
      unless page.text.blank?
        page.show_introduction = true
      end
      unless page.sidebar.blank?
        page.show_sidebar = true
      end
      unless page.interactive_items.length < 1
        page.show_interactive = true
      end
      unless page.page_items.length < 1
        page.show_info_assessment = true
      end
      page.save
    end
  end
end
