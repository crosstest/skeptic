# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crosstest/skeptic/version'

Gem::Specification.new do |spec|
  spec.name          = 'crosstest-skeptic'
  spec.version       = Crosstest::Skeptic::VERSION
  spec.authors       = ['Max Lincoln']
  spec.email         = ['max@devopsy.com']
  spec.summary       = 'Skeptic tests code samples do what they should.'
  # spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'crosstest-core', '~> 0'
  spec.add_dependency 'crosstest-psychic', '~> 0'
  spec.add_dependency 'hashie', '~> 3.0'
  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rake-notes'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.18', '<= 0.27'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.2'
  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'fabrication', '~> 2.11'
end
