class Sequence < ActiveRecord::Base
  attr_accessible :description, :title, :theme_id, :project_id, :user_id, :logo

  has_many :lightweight_activities_sequences, :order => :position, :dependent => :destroy
  has_many :lightweight_activities, :through => :lightweight_activities_sequences
  belongs_to :user
  belongs_to :theme
  belongs_to :project

  # TODO: Sequences and possibly activities will eventually belong to projects e.g. HAS, SFF

  def time_to_complete
    time = 0
    lightweight_activities.map { |a| time = time + (a.time_to_complete ? a.time_to_complete : 0) }
    time
  end

  def activities
    lightweight_activities
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
