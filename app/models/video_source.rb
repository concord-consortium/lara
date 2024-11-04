class VideoSource < ApplicationRecord
  # attr_accessible :url, :format
  
  SUPPORTED_MIME_TYPES = ["video/mp4", "video/webm", "video/ogg"] # Quicktime/mov?
  
  validates_presence_of :url
  validates_presence_of :format
  validates :format, inclusion: { in: SUPPORTED_MIME_TYPES }

  belongs_to :video_interactive

  def to_hash 
    {
      url: url,
      format: format
    }
  end

  def duplicate
    return VideoSource.new(self.to_hash)
  end
  
  def export
    return self.as_json(only:[:url,:format])
  end
end
