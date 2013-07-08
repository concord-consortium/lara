class Sequence < ActiveRecord::Base
  attr_accessible :description, :title, :theme, :user_id

  has_many :lightweight_activities_sequences, :order => :position, :dependent => :destroy
  has_many :lightweight_activities, :through => :lightweight_activities_sequences
  belongs_to :user
  belongs_to :theme

  # TODO: Sequences and possibly activities will eventually belong to projects e.g. HAS, SFF

  def time_to_complete
    time = 0
    lightweight_activities.map { |a| time = time + (a.time_to_complete ? a.time_to_complete : 0) }
    time
  end

  def activities
    lightweight_activities
  end
end
