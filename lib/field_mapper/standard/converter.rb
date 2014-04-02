module FieldMapper
  module Standard
    class Converter

      attr_reader :standard_plat, :standard_instance

      def initialize(standard_instance)
        @standard_plat = standard_instance.class
        @standard_instance = standard_instance
      end

      def convert_to(custom_plat)
        raise StandardMismatch if custom_plat.standard_plat != standard_plat

        custom_instance = custom_plat.new

        standard_plat.fields.each do |standard_field_name, standard_field|
          custom_fields = custom_plat.find_mapped_fields(standard_field)
          custom_fields.each do |custom_field|
            raw_custom_value = get_raw_custom_value(
              custom_field,
              standard_instance[standard_field_name],
              custom_instance
            )
            raw_custom_value = custom_field.cast(raw_custom_value)
            custom_instance[custom_field.name] = raw_custom_value
          end
        end

        [standard_instance, custom_instance].each do |instance|
          instance.send(:after_convert, from: standard_instance, to: custom_instance)
        end

        custom_instance
      end

      protected

      def get_raw_custom_value(custom_field, raw_standard_value, custom_instance)
        return nil if raw_standard_value.nil?

        strategy = custom_field.flip_strategy(:standard_to_custom)
        custom_flipper = custom_field.custom_flipper?(:standard_to_custom)

        if !custom_flipper
          if custom_field.plat?
            return compute_raw_custom_value_for_plat(custom_field, raw_standard_value)
          end

          if custom_field.plat_list?
            if custom_field.plat_list?
              return compute_raw_custom_value_for_plat_list(custom_field, raw_standard_value)
            end
          end
        end

        if strategy == :find
          if custom_field.type.is_a?(FieldMapper::Types::List)
            return raw_standard_value.map do |single_raw_standard_value|
              find_raw_custom_value(custom_field, single_raw_standard_value)
            end
          else
            return find_raw_custom_value(custom_field, raw_standard_value)
          end
        end

        compute_raw_custom_value(custom_field, raw_standard_value, custom_instance)
      end

      def find_raw_custom_value(custom_field, raw_standard_value)
        return raw_standard_value unless custom_field.has_values?

        if !custom_field.standard_field.has_values?
          custom_value = custom_field.find_value(raw_standard_value)
          return nil if custom_value.nil?
          return custom_value.value
        end

        custom_value = custom_field.find_priority_value_mapped_to_standard(raw_standard_value)
        return nil if custom_value.nil?
        custom_value.value
      end

      def compute_raw_custom_value(custom_field, raw_standard_value, custom_instance)
        raw_custom_value = custom_instance.instance_exec(
          raw_standard_value,
          standard_instance: standard_instance,
          &custom_field.standard_to_custom
        )

        if !raw_custom_value.nil?
          raw_custom_value = custom_field.cast(raw_custom_value)
        end
        raw_custom_value
      end

      def compute_raw_custom_value_for_plat_list(custom_field, raw_standard_values)
        raw_standard_values.map do |raw_standard_value|
          compute_raw_custom_value_for_plat(custom_field, raw_standard_value)
        end
      end

      def compute_raw_custom_value_for_plat(custom_field, raw_standard_value)
        converter = FieldMapper::Standard::Converter.new(raw_standard_value)
        converter.convert_to(custom_field.type.type)
      end

    end
  end
end

