require "simplecov"

if ENV["CI"]
  require "coveralls"
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
end

SimpleCov.command_name "micro_test"
SimpleCov.start do
  add_filter "/test/"
end

Coveralls.wear! if ENV["CI"]

require_relative "../lib/field_mapper"
