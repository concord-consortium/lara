class AddPageToRuns < ActiveRecord::Migration
  def change
    add_column :runs, :page_id, :integer
  end
end
