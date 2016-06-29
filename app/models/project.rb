class Project < ActiveRecord::Base
  DefaultName = 'Default Project'

  attr_accessible :footer, :logo, :title, :url, :theme_id, :about, :help
  has_many :sequences
  has_many :lightweight_activities
  belongs_to :theme

  protected
  def self.create_default
    self.create(:title => DefaultName, :logo => '', :url => 'http://concord.org/')
  end

  public
  def self.default
    self.find_by_title(DefaultName) || self.create_default
  end

  # Derive an OpenGraph-custom logo path from the provided path, or return the provided path if the OG logo doesn't exist
  def og_logo
    if logo
      logo_parts = logo.split('.')
      if logo_parts.length > 1
        # Insert '-og' before the extension but after the filename stem
        stem = "#{logo_parts.first(logo_parts.length - 1).join('.')}-og"
      else
        # No extension: just append '-og' on the end
        stem = "#{logo}-og"
      end
      # Check for stem as .jpg, .jpeg, .png and .gif, then give up
      ogl = nil
      %w(jpg jpeg png gif).each do |ext|
        proposed_filename = "#{stem}.#{ext}"
        if image_file_exists?(proposed_filename)
          ogl = proposed_filename
          break
        end
      end
      unless ogl
        # Can't find the og_logo - just go with the project logo
        ogl = logo
      end
      return ogl
    else
      return nil
    end
  end

  # Check if the derived OpenGraph logo file exists
  def image_file_exists?(filename)
    return File.exists?(Rails.root.join('public', 'assets', filename)) ||
           File.exists?(Rails.root.join('app', 'assets', 'images', filename))
  end
end
