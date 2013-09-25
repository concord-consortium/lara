class Sequence < ActiveRecord::Base
  attr_accessible :description, :title, :theme_id, :project_id, :user_id, :logo, :display_title
  include Publishable # models/publishable.rb defines pub & official
  has_many :lightweight_activities_sequences, :order => :position, :dependent => :destroy
  has_many :lightweight_activities, :through => :lightweight_activities_sequences
  belongs_to :user
  belongs_to :theme
  belongs_to :project


  scope :newest, order("updated_at DESC")
  # TODO: Sequences and possibly activities will eventually belong to projects e.g. HAS, SFF

  def time_to_complete
    time = 0
    lightweight_activities.map { |a| time = time + (a.time_to_complete ? a.time_to_complete : 0) }
    time
  end

  def activities
    lightweight_activities
  end

  def next_activity(activity)
    # Given an activity, return the next one in the sequence
    join = lightweight_activities_sequences.find_by_lightweight_activity_id(activity.id)
    if join && join.lower_item
      return join.lower_item.lightweight_activity
    else
      return nil
    end
  end

  def previous_activity(activity)
    # Given an activity, return the previous one in the sequence
    join = lightweight_activities_sequences.find_by_lightweight_activity_id(activity.id)
    if join.higher_item
      return join.higher_item.lightweight_activity
    else
      return nil
    end
  end

  def serialize_for_portal(host)
    local_url = "#{host}#{Rails.application.routes.url_helpers.sequence_path(self)}"
    data = {
      'type' => "Sequence",
      'name' => self.title,
      'description' => self.description,
      "url" => local_url,
      "create_url" => local_url
    }
    data['activities'] = self.activities.map{ |a| a.serialize_for_portal(host) }
    data
  end

end
