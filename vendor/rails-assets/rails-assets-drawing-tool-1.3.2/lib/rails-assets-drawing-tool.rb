require "rails-assets-drawing-tool/version"

require "rails-assets-fabric"
require "rails-assets-hammerjs"
require "rails-assets-jquery"
require "rails-assets-eventemitter2"

module RailsAssetsDrawingTool

  def self.gem_path
    Pathname(File.realpath(__FILE__)).join('../..')
  end

  def self.gem_spec
    Gem::Specification::load(
      gem_path.join("rails-assets-drawing-tool.gemspec").to_s
    )
  end

  def self.load_paths
    gem_path.join('app/assets').each_child.to_a
  end

  def self.dependencies
    [
      RailsAssetsFabric,
      RailsAssetsHammerjs,
      RailsAssetsJquery,
      RailsAssetsEventemitter2
    ]
  end

  if defined?(Rails)
    class Engine < ::Rails::Engine
      # Rails -> use app/assets directory.
    end
  end

end

class RailsAssets
  @components ||= []

  class << self
    attr_accessor :components

    def load_paths
      components.flat_map(&:load_paths)
    end
  end
end

RailsAssets.components << RailsAssetsDrawingTool
