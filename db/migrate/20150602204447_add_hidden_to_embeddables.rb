class AddHiddenToEmbeddables < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_image_questions, :is_hidden, :boolean, default: false
    add_column :embeddable_labbooks, :is_hidden, :boolean, default: false
    add_column :embeddable_multiple_choices, :is_hidden, :boolean, default: false
    add_column :embeddable_open_responses, :is_hidden, :boolean, default: false
    add_column :embeddable_xhtmls, :is_hidden, :boolean, default: false
  end
end
