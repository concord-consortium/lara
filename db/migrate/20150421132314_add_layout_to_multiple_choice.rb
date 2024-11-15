class AddLayoutToMultipleChoice < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_multiple_choices, :layout, :string, default: "vertical"
  end
end
