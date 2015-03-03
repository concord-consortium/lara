class Theme < ActiveRecord::Base
  DEFAULT_NAME = 'Default'
  DEFAULT_CSS_FILE = 'runtime'
  attr_accessible :name, :css_file

  protected
  def self.create_default
    self.create(:name => DEFAULT_NAME, :css_file => DEFAULT_CSS_FILE)
  end

  public
  def self.default
    self.find_by_name(DEFAULT_NAME) || self.create_default
  end

  # TODO: Footer might need to delegate to a future Project object instead of being part of Theme

  validates_presence_of :css_file, :name

  def css_file_exists?
    return File.exist?(Rails.root.join('app', 'assets', 'stylesheets', "#{css_file}.css")) || File.exist?(Rails.root.join('public', 'assets', "#{css_file}.css"))
  end
end
