# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubarb/version'

Gem::Specification.new do |spec|
  spec.name        = 'rubarb'
  spec.version     = Rubarb::VERSION
  spec.summary     = "Ruby Bar Boss"
  spec.description = "Process manager for running a bar for any tiling WM."
  spec.authors     = ["Jon Sagotsky"]
  spec.email       = 'valadil@gmail.com'
  spec.homepage    = 'https://github.com/sagotsky/rubarb'
  spec.files       = `git ls-files`.split($/)
  spec.license       = "MIT"

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", "lib/rubarb", "lib/rubarb/plugins"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "mocha"
end
