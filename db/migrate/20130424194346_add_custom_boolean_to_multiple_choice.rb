class AddCustomBooleanToMultipleChoice < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_multiple_choices, :custom, :boolean, :default => false
  end
end
