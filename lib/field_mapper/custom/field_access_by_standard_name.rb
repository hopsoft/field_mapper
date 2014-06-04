module FieldMapper
  class FieldAccessByStandardName

    def initialize(custom_plat)
      @custom_plat = custom_plat
      @fields_by_standard_name = custom_plat.class.fields_by_standard_name
    end

    def [](standard_name)
      custom_field = field(standard_name)
      custom_plat[custom_field.name]
    end

    def []=(standard_name, value)
      custom_field = field(standard_name)
      custom_plat[custom_field.name] = value
    end

    private

    attr_reader :custom_plat, :fields_by_standard_name

    def field(standard_name)
      fields_by_standard_name[standard_name.to_sym]
    end

  end
end
