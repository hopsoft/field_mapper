require_relative "../standard/field"
require_relative "value"

module FieldMapper
  module Custom
    class Field < FieldMapper::Standard::Field

      DefaultFlipper = -> (value, standard_instance: nil) { value }

      attr_reader(
        :name,
        :type,
        :desc,
        :default,
        :values,
        :standard_field,
        :custom_to_standard,
        :standard_to_custom
      )

      def initialize(
        name,
        type: nil,
        desc: nil,
        default: nil,
        placeholder: nil,
        standard_field: nil,
        custom_to_standard: DefaultFlipper,
        standard_to_custom: DefaultFlipper,
        &block
      )
        type ||= standard_field.type unless standard_field.nil?
        super name, type: type, desc: desc, default: default, placeholder: placeholder

        @standard_field = standard_field
        @custom_to_standard = custom_to_standard
        @standard_to_custom = standard_to_custom

        eigen = class << self; self; end
        eigen.instance_eval do
          define_method :custom_to_standard1, &custom_to_standard
          define_method :standard_to_custom2, &standard_to_custom
        end
      end

      attr_writer :placeholder

      def placeholder
        @placeholder || (standard_field && standard_field.placeholder)
      end

      def value(value, standard: nil, priority: nil)
        @values ||= []
        @values << FieldMapper::Custom::Value.new(
          value,
          field: self,
          standard_value: standard,
          priority: priority
        )
        @values.last
      end

      # Adds values to a Field instance that are defined in a CSV file.
      #
      # Intended use is from within a Plat class declaration.
      # @example
      #   class ExamplePlat < FieldMapper::Standard::Plat
      #     field :example do
      #       load_values "/path/to/file.csv"
      #     end
      #   end
      #
      # The format of the CSV file should contain a two columns with a header row.
      # NOTE: An optional priority column can also be included.
      # @example
      #   custom_value,standard_value,priority
      #   "A",1,
      #   "B",2,true
      #   "C",2,
      #
      def load_values(path_to_csv)
        CSV.foreach(path_to_csv, :headers => true) do |row|
          value(
            row["custom_value"],
            standard: row["standard_value"],
            priority: FieldMapper::Types::Boolean.parse(row["priority"])
          )
        end
      end

      def find_values_mapped_to_standard(standard_value)
        values.select do |val|
          val.standard_value == standard_value ||
            val.standard_value.value == standard_value
        end
      end

      def find_priority_value_mapped_to_standard(standard_value)
        matches = find_values_mapped_to_standard(standard_value)
        match = matches.find { |val| val.priority }
        match ||= matches.first
      end

      def flip_strategy(direction)
        return :compute if custom_flipper?(direction)
        return :find if has_values?
        return :find if standard_field.present? && standard_field.has_values?
        :compute
      end

      def custom_flipper?(direction)
        instance_variable_get("@#{direction}") != DefaultFlipper
      end

    end
  end
end
