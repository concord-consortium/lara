class AddLastPageToActivityResponses < ActiveRecord::Migration[5.1]
  def change
    add_column :activity_responses, :last_page, :integer, :null => true
  end
end
