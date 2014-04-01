require_relative "../errors"

module FieldMapper
  module Standard
    class Value
      attr_reader(
        :value,
        :field
      )

      def initialize(
        value,
        field: nil
      )
        raise ArgumentError.new("field is required") if
          field.nil?

        @field = field
        @value = field.cast(value, as_single_value: true)
      end
    end

  end
end
