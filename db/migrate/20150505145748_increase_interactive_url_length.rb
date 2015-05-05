class IncreaseInteractiveUrlLength < ActiveRecord::Migration
  def up
      change_column :mw_interactives, :url, :text, :limit => 2048
  end
  def down
      change_column :mw_interactives, :url, :string
  end
end
