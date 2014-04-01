require "active_support/all"
require "american_date"
require "money"
require_relative "field_mapper/version"
require_relative "field_mapper/types/boolean"
require_relative "field_mapper/types/plat"
require_relative "field_mapper/types/list"
require_relative "field_mapper/standard/plat"
require_relative "field_mapper/custom/plat"
require_relative "field_mapper/standard/converter"
require_relative "field_mapper/custom/converter"

module FieldMapper
  class << self
    attr_accessor :logger
  end
end
