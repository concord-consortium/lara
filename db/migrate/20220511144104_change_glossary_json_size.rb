class ChangeGlossaryJsonSize < ActiveRecord::Migration[5.1]
  def up
    change_column :glossaries, :json, :text, limit: 16777215
  end

  def down
    change_column :glossaries, :json, :text, limit: 65535
  end
end
