class RenameResponsive2ColumnsToResponsive3070 < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      UPDATE sections 
      SET layout = 'responsive-30-70' 
      WHERE layout = 'responsive-2-columns'
    SQL
  end

  def down
    execute <<-SQL
      UPDATE sections 
      SET layout = 'responsive-2-columns' 
      WHERE layout = 'responsive-30-70'
    SQL
  end
end
