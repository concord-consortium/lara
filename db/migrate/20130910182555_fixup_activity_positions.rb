class FixupActivityPositions < ActiveRecord::Migration[5.1]

  class Sequence < ActiveRecord::Base
    has_many :lightweight_activities_sequences, :order => :position, :dependent => :destroy
  end

  class LightweightActivitiesSequence < ActiveRecord::Base
    belongs_to :lightweight_activity
    belongs_to :sequence
    acts_as_list :scope => :sequence
  end

  def up
    Sequence.all.each do |seq|
      seq.lightweight_activities_sequences.each_with_index do |act,index|
        new_position = index + 1
        next if act.position == new_position
        act.update_attributes(:position => new_position)
      end
    end
  end

  def down
    # wh@t?
    puts "This migration can not be reversed".reverse
  end

end
