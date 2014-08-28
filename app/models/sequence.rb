class Sequence < ActiveRecord::Base
  attr_accessible :description, :title, :theme_id, :project_id, 
    :user_id, :logo, :display_title, :thumbnail_url, :abstract
  include Publishable # models/publishable.rb defines pub & official
  has_many :lightweight_activities_sequences, :order => :position, :dependent => :destroy
  has_many :lightweight_activities, :through => :lightweight_activities_sequences, :order => :position
  belongs_to :user
  belongs_to :theme
  belongs_to :project


  # scope :newest, order("updated_at DESC")
  # TODO: Sequences and possibly activities will eventually belong to projects e.g. HAS, SFF

  def name
    # activities have names, so to be consistent ...
    self.title
  end
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
    get_neighbor(activity, false)
  end

  def previous_activity(activity)
    # Given an activity, return the previous one in the sequence
    get_neighbor(activity, true)
  end

  def to_hash
    # We're intentionally not copying:
    # - publication status (the copy should start as draft like everything else)
    # - is_official (defaults to false, can be changed)
    # - user_id (the copying user should be the owner)
    {
      title: title,
      description: description,
      abstract: abstract,
      theme_id: theme_id,
      project_id: project_id,
      logo: logo,
      display_title: display_title,
      thumbnail_url: thumbnail_url
    }
  end

  def duplicate(new_owner)
    new_sequence = Sequence.new(self.to_hash)
    Sequence.transaction do
      new_sequence.title = "Copy of #{self.name}"
      new_sequence.user = new_owner
      positions = []
      lightweight_activities_sequences.each do |sa|
        new_a = sa.lightweight_activity.duplicate(new_owner)
        new_a.name = new_a.name.sub('Copy of ', '')
        new_a.save!
        new_sequence.activities << new_a
        positions << sa.position
      end
      new_sequence.save!
      # This is not necessary, as 'lightweight_activities_sequences' is ordered by
      # position, so we already copied and add activities in a right order. However
      # copying exact position values seems to be safer and more resistant
      # to possible errors in the future.
      new_sequence.lightweight_activities_sequences.each_with_index do |sa, i|
        sa.position = positions[i]
        sa.save!
      end
      new_sequence.save!
    end
    return new_sequence
  end

  def serialize_for_portal(host)
    local_url = "#{host}#{Rails.application.routes.url_helpers.sequence_path(self)}"
    data = {
      'type' => "Sequence",
      'name' => self.title,
      'description' => self.description,
      'abstract' => self.abstract,
      "url" => local_url,
      "create_url" => local_url,
      "thumbnail_url" => thumbnail_url
    }
    data['activities'] = self.activities.map { |a| a.serialize_for_portal(host) }
    data
  end

  private
  def get_neighbor(activity, higher)
    join = lightweight_activities_sequences.find_by_lightweight_activity_id(activity.id)
    if join.blank? || (join.first? && higher) || (join.last? && !higher)
      return nil
    elsif join && higher
      return join.higher_item.lightweight_activity
    elsif join && !higher
      return join.lower_item.lightweight_activity
    else
      return nil
    end
  end
end
