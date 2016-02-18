require "json"

module FieldMapper
  module Marshaller

    def marshal(value)
      JSON.dump prep_value(value)
    end

    def unmarshal(value)
      JSON.load value
    end

    private

    def prep_value(value)
      return value.map { |v| prep_value v } if value.is_a?(Array)
      return value.to_hash if value.is_a?(HashWithIndifferentAccess)
      value
    end

  end
end
