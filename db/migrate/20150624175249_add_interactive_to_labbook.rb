class AddInteractiveToLabbook < ActiveRecord::Migration
  def up
     change_table :embeddable_labbooks do |t|
       t.references :interactive, polymorphic: true
     end
     add_index :embeddable_labbooks, :interactive_id,   name: "labbook_interactive_i_idx"
     add_index :embeddable_labbooks, :interactive_type, name: "labbook_interactive_t_idx"
   end

  def down
     change_table :embeddable_labbooks do |t|
       t.remove_references :interactive, polymorphic: true, index: true
     end
     # column indexes are removed when columns are removed.
  end
end
