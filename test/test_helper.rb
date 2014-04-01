require_relative "../lib/field_mapper"
require "simplecov"
require 'coveralls'
SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.command_name "micro_test"
SimpleCov.start do
  add_filter "/test/"
end
Coveralls.wear!
