require "csv"
require "oj"
require_relative "value"

module FieldMapper
  module Standard
    class Field
      include FieldMapper::Marshaller

      attr_reader(
        :name,
        :type,
        :desc,
        :default,
        :values
      )

      def initialize(
        name,
        type: nil,
        desc: nil,
        default: nil
      )
        raise TypeNotSpecified.new("type not specified for: #{name}") if type.nil?
        @name = name.to_sym
        @type = type
        @desc= desc
        @default = default
      end

      def list?
        type.name == "FieldMapper::Types::List"
      end

      def plat?
        type.name == "FieldMapper::Types::Plat"
      end

      def plat_field?
        plat? || plat_list?
      end

      def plat_list?
        list? && type.plat_list?
      end

      def raw_values
        return nil unless has_values?
        values.map { |v| v.value }
      end

      # Adds a value to a Field instance.
      # Intended use is from within a Plat class declaration.
      #
      # @example
      #   class ExamplePlat < FieldMapper::Standard::Plat
      #     field :example do
      #       value 1
      #     end
      #   end
      def value(val)
        @values ||= []
        @values << FieldMapper::Standard::Value.new(val, field: self)
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
      # The format of the CSV file should contain a single column with a header row.
      # @example
      #   Name of Field
      #   1
      #   2
      #
      def load_values(path_to_csv)
        CSV.foreach(path_to_csv, :headers => true) do |row|
          value row["standard_value"].to_s.strip
        end
      end

      def has_values?
        !values.nil?
      end

      def find_value(value)
        return nil unless has_values?
        values.find { |val| val == value || val.value == value }
      end

      def cast(value, as_single_value: false)
        value = cast_value(type, value, as_single_value: as_single_value)
        return nil if value.nil? || value.to_s.blank?
        value = clean_value(value) unless as_single_value
        value
      end

      alias_method :to_s, :name

      private

      def cast_value(type, value, as_single_value: false)
        return nil if value.nil?
        case type.name
        when "String"                       then return string(value)
        when "FieldMapper::Types::Boolean"  then return boolean(value)
        when "Time"                         then return time(value)
        when "Integer"                      then return value.to_i
        when "Float"                        then return value.to_f
        when "Money"                        then return money(value)
        when "FieldMapper::Types::Plat"     then return plat_instance(type, value)
        when "FieldMapper::Types::List"     then
          return cast_value(type.type, value) if as_single_value
          return plat_instance_list(type, value) if type.plat_list?
          get_list value
        else
          nil
        end
      end

      def get_list(value)
        value = unmarshal(value) if value.is_a?(String)
        value.map { |val| cast_value(type.type, val) }
      end

      def clean_value(value)
        return value unless has_values?
        return value unless type.name == "FieldMapper::Types::List"
        value & raw_values
      end

      def string(value)
        return value if value.is_a?(String)
        value.to_s.strip
      end

      def boolean(value)
        return value if value.is_a?(TrueClass) || value.is_a?(FalseClass)
        FieldMapper::Types::Boolean.parse(value)
      end

      def time(value)
        return value if value.is_a?(Time)
        Time.parse(value.to_s).utc rescue nil
      end

      def money(value)
        return value if value.is_a?(Money)
        return Monetize.parse(value) rescue nil
      end

      def plat_instance(type, value)
        return value if value.is_a?(FieldMapper::Standard::Plat)
        return value if value.is_a?(Numeric)
        return value.to_i if value.is_a?(String) && value =~ /\A\d+\z/
        return type.type.new(value) if value.is_a?(Hash)
        return type.type.new(unmarshal(value)) if value.is_a?(String)
        nil
      end

      def plat_instance_list(type, value)
        return value if value.is_a?(Array) && value.empty?
        value = unmarshal(value) if value.is_a?(String)
        return value.map { |val| plat_instance(type, val) }
      end

    end
  end
end
