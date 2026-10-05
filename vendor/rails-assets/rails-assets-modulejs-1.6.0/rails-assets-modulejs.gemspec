# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-modulejs/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-modulejs"
  spec.version       = RailsAssetsModulejs::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "lightweight JavaScript module system"
  spec.summary       = "lightweight JavaScript module system"
  spec.homepage      = "http://larsjung.de/modulejs"
  spec.license       = "MIT"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
