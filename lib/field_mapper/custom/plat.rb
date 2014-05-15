require_relative "../standard/plat"
require_relative "../errors"
require_relative "../name_helper"
require_relative "field"

module FieldMapper
  module Custom
    class Plat < FieldMapper::Standard::Plat

      class << self
        attr_reader :standard_plat

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

        def find_mapped_fields(standard_field)
          fields.values.select { |field| field.standard_field == standard_field }
        end
      end

    end
  end
end
