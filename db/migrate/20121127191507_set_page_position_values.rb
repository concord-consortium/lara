class SetPagePositionValues < ActiveRecord::Migration
  def up
    LightweightActivity.all.each do |act|
      pos = 1
      act.pages.each do |p|
        p.position = pos
        p.save
        pos += 1
      end
    end
  end

  def down
    InteractivePage.all.each do |p|
      p.position = nil
      p.save
    end
  end
end
