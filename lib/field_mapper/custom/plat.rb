require_relative "../standard/plat"
require_relative "../errors"
require_relative "../name_helper"
require_relative "field"
require_relative "field_access_by_standard_name"

module FieldMapper
  module Custom
    class Plat < FieldMapper::Standard::Plat

      class << self
        attr_reader :standard_plat

        def inherited(subclass)
          if @standard_plat.present?
            subclass.set_standard(@standard_plat)

            if fields.keys.any?
              subclass._fields = @_fields
            end

            if field_names.keys.any?
              subclass.._field_names = @_field_names
            end
          end
        end

        def set_standard(standard_plat)
          @standard_plat = standard_plat
        end

        def field(
          name,
          type: nil,
          desc: nil,
          default: nil,
          placeholder: nil,
          standard: nil,
          custom_to_standard: FieldMapper::Custom::Field::DefaultFlipper,
          standard_to_custom: FieldMapper::Custom::Field::DefaultFlipper,
          &block
        )
          field_names[attr_name(name)] = name

          field = fields[name] = FieldMapper::Custom::Field.new(
            name,
            type: type,
            desc: desc,
            default: default,
            placeholder: placeholder,
            standard_field: standard_plat.fields[standard],
            custom_to_standard: custom_to_standard,
            standard_to_custom: standard_to_custom
          )

          field.instance_exec(&block) if block_given?

          define_method(attr_name name) do
            self[name]
          end

          define_method("#{attr_name name}=") do |value|
            self[name] = value
          end
        end

        def basic_mapped_fields(*names)
          names.each { |name| basic_mapped_field(name) }
        end

        def basic_mapped_field(name)
          field name, standard: name
        end

        def find_mapped_fields(standard_field)
          fields.values.select { |field| field.standard_field == standard_field }
        end

        def fields_by_standard_name
          @fields_by_standard_name ||= fields.values.reduce({}) do |memo, field|
            memo[field.standard_field.name] = field unless field.standard_field.nil?
            memo
          end
        end

        def standard_keys_to_custom_keys(standard_keyed_params)
          standard_keyed_params.reduce({}) do |memo, standard_param|
            key = standard_param.first
            value = standard_param.last
            field = fields_by_standard_name[key.to_sym]

            if !field.nil?
              case field.type.name
              when "FieldMapper::Types::Plat" then
                if value.is_a?(Hash)
                  value = field.type.type.standard_keys_to_custom_keys(value)
                end
              when "FieldMapper::Types::List" then
                if field.type.type.ancestors.include?(Plat)
                  if value.is_a?(Array)
                    value = value.compact.map do |val|
                      field.type.type.standard_keys_to_custom_keys(val)
                    end
                  end
                end
              end
              memo[field.name] = value
            end

            memo
          end
        end

        def new_from_standard_keyed_params(standard_keyed_params)
          new standard_keys_to_custom_keys(standard_keyed_params)
        end
      end

      def standard_name
        @standard_name ||= FieldAccessByStandardName.new(self)
      end

    end
  end
end
