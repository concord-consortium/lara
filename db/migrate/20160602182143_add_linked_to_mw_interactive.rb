class AddLinkedToMwInteractive < ActiveRecord::Migration[5.1]
  def change
    add_column :mw_interactives, :linked_interactive_id, :integer
    add_index :mw_interactives, :linked_interactive_id
  end
end
