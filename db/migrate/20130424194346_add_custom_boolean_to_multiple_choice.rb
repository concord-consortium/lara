class AddCustomBooleanToMultipleChoice < ActiveRecord::Migration
  def change
    add_column :embeddable_multiple_choices, :custom, :boolean, :default => false
  end
end
