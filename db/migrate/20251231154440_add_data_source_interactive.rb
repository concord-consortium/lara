class AddDataSourceInteractive < ActiveRecord::Migration[8.0]
  def change
    add_column :mw_interactives, :data_source_interactive_type, :string
    add_column :mw_interactives, :data_source_interactive_id, :integer

    add_column :managed_interactives, :data_source_interactive_type, :string
    add_column :managed_interactives, :data_source_interactive_id, :integer
  end
end
