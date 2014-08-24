# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'warren/version'

Gem::Specification.new do |spec|
  spec.name          = "warren"
  spec.version       = Warren::VERSION
  spec.authors       = ["Lin He"]
  spec.email         = ["he9lin@gmail.com"]
  spec.summary       = %q{A DSL wrapper around bunny to run distributed and communicating apps.}

  spec.description   = %q{A DSL wrapper around bunny to run distributed and communicating apps.}
  spec.homepage      = "https://bitbucket.org/he9lin/warren"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "bunny"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0.0"
  spec.add_development_dependency "guard-rspec"
end
