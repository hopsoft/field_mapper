# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'field_mapper/version'

Gem::Specification.new do |spec|
  spec.name          = "field_mapper"
  spec.version       = FieldMapper::VERSION
  spec.authors       = ["Nathan Hopkins"]
  spec.email         = ["natehop@gmail.com"]
  spec.description   = "Data mapping & transformation"
  spec.summary       = "Data mapping & transformation"
  spec.homepage      = "https://github.com/hopsoft/field_mapper"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb"]
  spec.test_files    = Dir["test/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.6"

  spec.add_dependency "activesupport", "~> 6.0"
  spec.add_dependency "american_date"
  spec.add_dependency "money"
  spec.add_dependency "monetize"
  spec.add_dependency "oj"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry-test"
  spec.add_development_dependency "coveralls"
end
