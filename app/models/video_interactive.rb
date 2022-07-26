class VideoInteractive < ActiveRecord::Base
  include Embeddable

  has_many :page_items, :as => :embeddable, :dependent => :destroy
  # PageItem is a join model; if this is deleted, that instance should go too
  has_one :interactive_page, :through => :page_item
  has_many :sources, :class_name => 'VideoSource',
           :foreign_key => 'video_interactive_id',
           :dependent => :destroy # If we delete this video we should dump its sources

  # TODO: Not sure if labbooks work with video interactives.
  has_one :labbook, :as => :interactive, :class_name => 'Embeddable::Labbook'

  attr_accessible :poster_url, :caption, :credit, :height, :width, :sources_attributes, :is_hidden, :is_full_width

  accepts_nested_attributes_for :sources, :allow_destroy => true

  validates_numericality_of :height, :width

  def self.portal_type
    "unsupported"
  end

  # returns the aspect ratio of the interactive, determined by dividing the width by the height.
  # So for an interactive with a native width of 400 and native height of 200, the aspect_ratio
  # will be 2.
  def aspect_ratio
    if self.width && self.height
      return self.width/self.height.to_f
    else
      return 1.324 # Derived from the default values, above
    end
  end

  def calculated_height(width)
    return width/self.aspect_ratio
  end

  def activity
    if interactive_page
      return self.interactive_page.lightweight_activity
    else
      return nil
    end
  end

  def reportable?
    false
  end

  def no_snapshots
    false
  end

  def page_section
    # In practice one question can't be added to multiple pages. Perhaps it should be refactored to has_one / belongs_to relation.
    page_items.count > 0 && page_items.first.section
  end

  def to_hash
    {
      poster_url: poster_url,
      caption: caption,
      credit: credit,
      height: height,
      width: width,
      is_hidden: is_hidden,
      is_full_width: is_full_width
    }
  end

  def duplicate
    vi = VideoInteractive.new(self.to_hash)
    vi.sources = self.sources.map { |vs| vs.duplicate }
    return vi
  end

  def export
    video_interactive_export = self.as_json(only:[:poster_url,
                                                  :caption,
                                                  :credit,
                                                  :height,
                                                  :width,
                                                  :is_full_width,
                                                  :is_hidden])

    video_interactive_export[:sources] =  []

    self.sources.each do |source|
       video_interactive_export[:sources] << source.export
    end

    video_interactive_export
  end

  def self.import(import_hash)
    import_video_interactive = self.new(import_hash.except(:sources))
    import_hash[:sources].each do |source|
      import_source = VideoSource.new(source)
      import_video_interactive.sources << import_source
    end
    import_video_interactive
  end
end
