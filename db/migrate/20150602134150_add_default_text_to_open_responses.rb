class AddDefaultTextToOpenResponses < ActiveRecord::Migration
  def change
    add_column :embeddable_open_responses, :default_text, :string
  end
end
