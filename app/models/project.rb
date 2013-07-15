class Project < ActiveRecord::Base
  attr_accessible :footer, :logo, :title, :url
  has_many :sequences
  has_many :lightweight_activities

  # Derive an OpenGraph-custom logo path from the provided path, or return the provided path if the OG logo doesn't exist
  def og_logo
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
  end

  # Check if the derived OpenGraph logo file exists
  def image_file_exists?(filename)
    return File.exists?(Rails.root.join('public', 'assets', filename)) ||
           File.exists?(Rails.root.join('app', 'assets', 'images', filename))
  end
end
