class AddEmbeddableDisplayToPage < ActiveRecord::Migration
  def change
    add_column :interactive_pages, :embeddable_display_mode, :string, default: 'stacked'
  end
end
