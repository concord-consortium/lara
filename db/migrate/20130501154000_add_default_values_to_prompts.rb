class AddDefaultValuesToPrompts < ActiveRecord::Migration
  def change
    change_column :embeddable_multiple_choices, :prompt, :text, :default => "Why does ..."
    change_column :embeddable_open_responses, :prompt, :text, :default => "Why does ..."
  end
end
