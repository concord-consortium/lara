class FixupPagePositions < ActiveRecord::Migration
  class LightweightActivity < ActiveRecord::Base
    has_many :pages, :foreign_key => 'lightweight_activity_id', :class_name => 'InteractivePage', :order => :position
  end

  class InteractivePage < ActiveRecord::Base
    belongs_to :lightweight_activity, :class_name => 'LightweightActivity', :touch => true
    acts_as_list :scope => :lightweight_activity
  end

  def up
    LightweightActivity.all.each do |act|
      act.pages.each_with_index do |page,index|
        new_position = index + 1
        next if page.position == new_position
        page.update_attributes(:position => new_position)
      end
    end
  end

  def down
    # wh@t?
    puts "This migration can not be reversed".reverse
  end

end
