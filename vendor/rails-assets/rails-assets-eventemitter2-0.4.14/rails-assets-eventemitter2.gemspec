# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-eventemitter2/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-eventemitter2"
  spec.version       = RailsAssetsEventemitter2::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "A Node.js event emitter implementation with namespaces, wildcards, TTL and browser support."
  spec.summary       = "A Node.js event emitter implementation with namespaces, wildcards, TTL and browser support."
  spec.homepage      = "https://github.com/hij1nx/EventEmitter2"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
