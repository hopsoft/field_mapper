require_relative "../errors"

module FieldMapper
  module Custom
    class Value < FieldMapper::Standard::Value
      attr_reader(
        :value,
        :field,
        :priority,
        :standard_value
      )

      def initialize(
        value,
        field: nil,
        priority: nil,
        standard_value: nil
      )
        super value, field: field

        if !standard_value.nil?
          if field.standard_field.nil?
            message = "[#{field.name}] [#{value}] is mapped to a standard but [#{field.name}] is not"
            raise StandardFieldNotFound.new(message)
          end

          raw_standard_value = standard_value
          standard_value = field.standard_field.find_value(standard_value)

          if standard_value.nil?
            message = "[#{field.name}] [#{value}] is mapped, but the standard [#{field.standard_field.name}] doesn't define the value [#{raw_standard_value}]"
            raise StandardValueNotFound.new(message)
          end
        end

        @priority = priority
        @standard_value = standard_value
      end
    end
  end
end
