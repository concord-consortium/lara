# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-fabric/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-fabric"
  spec.version       = RailsAssetsFabric::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "Object model for HTML5 canvas, and SVG-to-canvas parser. Backed by jsdom and node-canvas."
  spec.summary       = "Object model for HTML5 canvas, and SVG-to-canvas parser. Backed by jsdom and node-canvas."
  spec.homepage      = "http://fabricjs.com/"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
