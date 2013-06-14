class VideoInteractive < ActiveRecord::Base
  has_one :interactive_item, :as => :interactive, :dependent => :destroy
  # InteractiveItem is a join model; if this is deleted, that instance should go too
  has_one :interactive_page, :through => :interactive_item
  has_many :sources, :class_name => 'VideoSource',
           :foreign_key => 'video_interactive_id',
           :dependent => :destroy # If we delete this video we should dump its sources

  attr_accessible :poster_url, :caption, :credit, :sources_attributes

  accepts_nested_attributes_for :sources, :allow_destroy => true

  def activity
    if interactive_page
      return self.interactive_page.lightweight_activity
    else
      return nil
    end
  end

  def to_hash
    {
      poster_url: poster_url,
      caption: caption,
      credit: credit
    }
  end

  def duplicate
    vi = VideoInteractive.new(self.to_hash)
    vi.sources = self.sources.map { |vs| vs.duplicate }
    return vi
  end
end
