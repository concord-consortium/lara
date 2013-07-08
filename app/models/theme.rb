class Theme < ActiveRecord::Base
  attr_accessible :name, :footer, :css_file

  # TODO: Footer might need to delegate to a future Project object instead of being part of Theme

  validates_presence_of :css_file, :name

  def css_file_exists?
    return File.exist?(Rails.root.join('app', 'assets', 'stylesheets', "#{css_file}.css")) || File.exist?(Rails.root.join('public', 'assets', "#{css_file}.css"))
  end
end
