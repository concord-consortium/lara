class AddOptionsToLabbook < ActiveRecord::Migration
  def change
    add_column :embeddable_labbooks, :action_type, :integer, null: false, default: 0
    add_column :embeddable_labbooks, :name, :string
    add_column :embeddable_labbooks, :prompt, :text
    add_column :embeddable_labbooks, :custom_action_label, :string
  end
end
