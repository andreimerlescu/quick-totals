# coding: utf-8
lib = File.expand_path "../lib", __FILE__
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "quick-totals/version"

Gem::Specification.new do |spec|
  spec.name          = "quick-totals"
  spec.version       = `cat VERSION`
  spec.authors       = ["Patriot Phoenix"]
  spec.email         = ["me@patriotphoenix.com"]
  spec.description   = %q{Totals/count caching for mongoid models using redis}
  spec.summary       = %q{Totals/couch caching for mongoid models using redis}
  spec.homepage      = "https://github.com/patriotphoenix/quick-totals"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mongoid"
  spec.add_dependency "active_support"
  spec.add_dependency "unique-identifier"
  # spec.add_development_dependency "name", "~> 0.0"
end