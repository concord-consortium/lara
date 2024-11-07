class AddPageToRuns < ActiveRecord::Migration[5.1]
  def change
    add_column :runs, :page_id, :integer
  end
end
