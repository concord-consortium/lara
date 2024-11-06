class ChangeResponseStringToText < ActiveRecord::Migration
  def up
    change_table :portal_publications do |t|
      t.change :response, :text
    end
  end

  def down
    change_table :portal_publications do |t|
      t.change :response, :string
    end
  end
end
