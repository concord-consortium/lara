class AddDefaultTextToOpenResponses < ActiveRecord::Migration[5.1]
  def change
    add_column :embeddable_open_responses, :default_text, :string
  end
end
