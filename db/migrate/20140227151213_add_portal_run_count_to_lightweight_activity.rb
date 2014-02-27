class AddPortalRunCountToLightweightActivity < ActiveRecord::Migration
  class Tun < ActiveRecord::Base
   set_table_name :runs
  end 

  class Act < ActiveRecord::Base
    set_table_name :lightweight_activities
    attr_accessible :portal_run_count
    has_many :runs, :foreign_key => 'activity_id', :class_name => Tun
  end

  def up
    add_column :lightweight_activities, :portal_run_count, :integer, :default => 0
    Act.all.each do |act|
      c = act.runs.where("remote_endpoint IS NOT NULL").count
      act.update_attribute(:portal_run_count,c)
    end
  end

  def down
    remove_column :lightweight_activities, :portal_run_count
  end
end
