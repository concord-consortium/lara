class AddComponentLabelToPlugins < ActiveRecord::Migration[5.1]
  def change
    add_column :plugins, :component_label, :string
  end
end
