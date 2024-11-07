class AddEmbeddableDisplayToPage < ActiveRecord::Migration[5.1]
  def change
    add_column :interactive_pages, :embeddable_display_mode, :string, default: 'stacked'
  end
end
