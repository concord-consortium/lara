class AddLastPageToActivityResponses < ActiveRecord::Migration
  def change
    add_column :activity_responses, :last_page, :integer, null: true
  end
end
