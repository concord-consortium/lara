class AddComponentLabelToPlugins < ActiveRecord::Migration
  def change
    add_column :plugins, :component_label, :string
  end
end
