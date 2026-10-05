# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-drawing-tool/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-drawing-tool"
  spec.version       = RailsAssetsDrawingTool::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = ""
  spec.summary       = ""
  spec.homepage      = "https://github.com/concord-consortium/drawing-tool"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_dependency "rails-assets-fabric", "1.5.0"
  spec.add_dependency "rails-assets-hammerjs", "~> 2.0.4"
  spec.add_dependency "rails-assets-jquery", "~> 2.1.3"
  spec.add_dependency "rails-assets-eventemitter2", "~> 0.4.14"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
