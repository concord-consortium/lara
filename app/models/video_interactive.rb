class VideoInteractive < ActiveRecord::Base
  attr_accessible :poster_url, :caption, :credit

  has_one :interactive_item, :as => :interactive, :dependent => :destroy
  # InteractiveItem is a join model; if this is deleted, that instance should go too

  has_one :interactive_page, :through => :interactive_item
  has_many :video_sources, :dependent => :destroy
  accepts_nested_attributes_for :video_sources, :allow_destroy => true

  def to_hash
    {
      poster_url: poster_url,
      caption: caption,
      credit: credit
    }
  end

  def duplicate
    vi = VideoInteractive.new(self.to_hash)
    vi.video_sources = self.video_sources.map { |vs| vs.duplicate }
    return vi
  end
end
