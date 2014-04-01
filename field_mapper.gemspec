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

  spec.add_dependency "activesupport", "~> 4.0.1"
  spec.add_dependency "american_date", "~> 1.1.0"
  spec.add_dependency "money",         "~> 6.1.1"
  spec.add_dependency "monetize"       #"~> 0.2.0"
  spec.add_dependency "oj",            "~> 2.7.1"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "micro_test"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-stack_explorer"
  spec.add_development_dependency "coveralls"
end
