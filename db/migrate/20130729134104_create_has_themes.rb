class CreateHasThemes < ActiveRecord::Migration
  def up
    water = Theme.new(:name => 'HAS National Geographic: Water', :css_file => 'theme-has-ngs-water')
    water.save
    land = Theme.new(:name => 'HAS National Geographic: Land Management', :css_file => 'theme-has-ngs-landmanagement')
    land.save
    frack = Theme.new(:name => 'HAS National Geographic: Hydrofracking', :css_file => 'theme-has-ngs-hydrofracking')
    frack.save
    climate = Theme.new(:name => 'HAS National Geographic: Climate', :css_file => 'theme-has-ngs-climate')
    climate.save
    atmosphere = Theme.new(:name => 'HAS National Geographic: Atmosphere', :css_file => 'theme-has-ngs-atmosphere')
    atmosphere.save
  end

  def down
  end
end
