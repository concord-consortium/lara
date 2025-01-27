class AddPortalRunCountToLightweightActivity < ActiveRecord::Migration[5.1]
  class Tun < ApplicationRecord
   self.table_name = 'runs'
  end 

  class Act < ApplicationRecord
    self.table_name = 'lightweight_activities'
    has_many :runs, foreign_key: 'activity_id', class_name: "Tun"
  end

  def up
    add_column :lightweight_activities, :portal_run_count, :integer, default: 0
    Act.all.each do |act|
      c = act.runs.where("remote_endpoint IS NOT NULL").count
      act.update_attribute(:portal_run_count,c)
    end
  end

  def down
    remove_column :lightweight_activities, :portal_run_count
  end
end
