# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'copy_method/version'

Gem::Specification.new do |spec|
  spec.name          = "copy_method"
  spec.version       = CopyMethod::VERSION
  spec.authors       = ["Alexa Grey"]
  spec.email         = ["devel@mouse.vc"]

  spec.summary       = %q{Copy a method from one class to another (experimental)}
  spec.description   = %q{Copy a method from one class to another (experimental)}
  spec.homepage      = "https://github.com/scryptmouse/copy_method"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '~> 2.1'

  spec.add_dependency "method_source", ">= 0.8"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "simplecov", '~> 0.10'
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "pry"
end
