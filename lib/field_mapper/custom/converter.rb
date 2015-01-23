module FieldMapper
  module Custom
    class Converter

      attr_reader(
        :custom_plat,
        :standard_plat,
        :custom_instance
      )

      def initialize(custom_instance)
        @custom_plat = custom_instance.class
        @custom_instance = custom_instance
        @standard_plat = custom_plat.standard_plat
      end

      def convert_to_standard(memoize: true)
        @converterd_to_standard = nil unless memoize
        @converterd_to_standard ||= begin
          standard_instance = standard_plat.new

          custom_plat.fields.each do |custom_field_name, custom_field|
            if custom_field.standard_field.present?
              raw_standard_value = get_raw_standard_value(
                custom_field,
                custom_instance[custom_field_name],
                standard_instance
              )
              raw_standard_value = custom_field.standard_field.cast(raw_standard_value)
              standard_instance[custom_field.standard_field.name] = raw_standard_value
            end
          end

          [custom_instance, standard_instance].each do |instance|
            instance.send(:after_convert, from: custom_instance, to: standard_instance)
          end

          standard_instance
        end
      end

      def convert_to(custom_plat, memoize: true)
        @converted_to_custom ||= {}
        @converted_to_custom[custom_plat] = nil unless memoize
        @converted_to_custom[custom_plat] ||= begin
          converter = FieldMapper::Standard::Converter.new(convert_to_standard)
          converter.convert_to(custom_plat)
        end
      end

      protected

      def get_raw_standard_value(custom_field, raw_custom_value, standard_instance)
        strategy = custom_field.flip_strategy(:custom_to_standard)
        custom_flipper = custom_field.custom_flipper?(:custom_to_standard)

        if !custom_flipper
          if raw_custom_value.nil?
            return [] if custom_field.standard_field.list_with_emtpy_default?
            return nil
          end

          if custom_field.plat?
            return compute_raw_standard_value_for_plat(custom_field, raw_custom_value)
          end

          if custom_field.plat_list?
            return compute_raw_standard_value_for_plat_list(custom_field, raw_custom_value)
          end
        end

        if strategy == :find
          if custom_field.list?
            return raw_custom_value.map do |single_raw_custom_value|
              find_raw_standard_value(custom_field, single_raw_custom_value)
            end
          else
            return find_raw_standard_value(custom_field, raw_custom_value)
          end
        end

        compute_raw_standard_value(custom_field, raw_custom_value, standard_instance)
      end

      def find_raw_standard_value(custom_field, raw_custom_value)
        return raw_custom_value unless custom_field.standard_field.has_values?

        if custom_field.has_values?
          custom_value = custom_field.find_value(raw_custom_value)
          if custom_value.present?
            custom_value.standard_value.value if custom_value.standard_value.present?
          end
        else
          standard_value = custom_field.standard_field.find_value(raw_custom_value)
          standard_value.value if standard_value.present?
        end
      end

      def compute_raw_standard_value(custom_field, raw_custom_value, standard_instance)
        raw_standard_value = custom_instance.instance_exec(
          raw_custom_value,
          standard_instance: standard_instance,
          &custom_field.custom_to_standard
        )

        if !raw_standard_value.nil?
          raw_standard_value = custom_field.standard_field.cast(raw_standard_value)
        end

        raw_standard_value
      end

      def compute_raw_standard_value_for_plat_list(custom_field, raw_custom_values)
        raw_custom_values.map do |raw_custom_value|
          compute_raw_standard_value_for_plat(custom_field, raw_custom_value)
        end
      end

      def compute_raw_standard_value_for_plat(custom_field, raw_custom_value)
        converter = FieldMapper::Custom::Converter.new(raw_custom_value)
        converter.convert_to_standard
      end

    end
  end
end
