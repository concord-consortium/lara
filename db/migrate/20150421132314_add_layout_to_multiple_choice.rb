class AddLayoutToMultipleChoice < ActiveRecord::Migration
  def change
    add_column :embeddable_multiple_choices, :layout, :string, :default => "vertical"
  end
end
