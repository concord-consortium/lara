class DropActivityReponses < ActiveRecord::Migration
  def up
    # activity_response functionality taken over by runs
    drop_table "activity_responses"
  end

  def down
    # recreate the table when undoing the drop
    create_table "activity_responses", :force => true do |t|
      t.string   "key",         :null => false
      t.text     "responses"
      t.integer  "activity_id", :null => false
      t.integer  "user_id"
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
      t.integer  "last_page"
    end
  end
end
