require_relative "../test_helper"

module Custom
  class FieldTest < PryTest::Test

    test "constructor requires type" do
      begin
        FieldMapper::Custom::Field.new(:foo)
      rescue FieldMapper::TypeNotSpecified => e
        error = e
      end
      assert error.present?
    end

    test "constructor sets standard field" do
      standard_field = FieldMapper::Standard::Field.new(:foo, type: String)
      custom_field = FieldMapper::Custom::Field.new(:bar, standard_field: standard_field)
      assert custom_field.standard_field == standard_field
    end

    test "constructor sets default flippers" do
      standard_field = FieldMapper::Standard::Field.new(:foo, type: String)
      custom_field = FieldMapper::Custom::Field.new(:bar, standard_field: standard_field)
      assert custom_field.respond_to?(:custom_to_standard)
      assert custom_field.respond_to?(:standard_to_custom)
    end

    test "inherits standard_field's type" do
      standard_field = FieldMapper::Standard::Field.new(:foo, type: FieldMapper::Types::Boolean)
      custom_field = FieldMapper::Custom::Field.new(:bar, standard_field: standard_field)
      assert custom_field.type == FieldMapper::Types::Boolean
    end

    test "custom_to_standard (default)" do
      standard_field = FieldMapper::Standard::Field.new(:foo, type: String)
      custom_field = FieldMapper::Custom::Field.new(:bar, standard_field: standard_field)
      assert custom_field.custom_to_standard.call("foobar") == "foobar"
    end

    test "custom_to_standard (override)" do
      standard_field = FieldMapper::Standard::Field.new(:foo, type: String)
      custom_field = FieldMapper::Custom::Field.new(
        :bar,
        standard_field: standard_field,
        custom_to_standard: -> (value, params: {}) { "override" }
      )
      assert custom_field.custom_to_standard.call("foobar") == "override"
    end

    test "standard_to_custom (default)" do
      standard_field = FieldMapper::Standard::Field.new(:foo, type: String)
      custom_field = FieldMapper::Custom::Field.new(:bar, standard_field: standard_field)
      assert custom_field.standard_to_custom.call("foobar") == "foobar"
    end

    test "standard_to_custom (override)" do
      standard_field = FieldMapper::Standard::Field.new(:foo, type: String)
      custom_field = FieldMapper::Custom::Field.new(
        :bar,
        standard_field: standard_field,
        standard_to_custom: -> (value, **) { "override" }
      )
      assert custom_field.standard_to_custom.call("foobar") == "override"
    end

    test "add value" do
      standard_field = FieldMapper::Standard::Field.new(:foo, type: String)
      standard_field.value("a")
      custom_field = FieldMapper::Custom::Field.new(:bar, standard_field: standard_field)
      custom_field.value("A", standard: "a")
      assert custom_field.values.first.value == "A"
      assert custom_field.values.first.standard_value.value == "a"
    end

    test "add value with priority" do
      standard_field = FieldMapper::Standard::Field.new(:foo, type: String)
      standard_field.value("a")
      custom_field = FieldMapper::Custom::Field.new(:bar, standard_field: standard_field)
      custom_field.value("A", standard: "a", priority: true)
      assert custom_field.values.first.priority
    end

    test "find_values_mapped_to_standard" do
      standard_field = FieldMapper::Standard::Field.new(:foo, type: String)
      standard_field.value("a")
      standard_field.value("b")
      custom_field = FieldMapper::Custom::Field.new(:bar, standard_field: standard_field)
      custom_field.value("A", standard: "a")
      custom_field.value("B", standard: "b")
      assert custom_field.find_values_mapped_to_standard(standard_field.values.first).include?(custom_field.values.first)
      assert custom_field.find_values_mapped_to_standard("a").include?(custom_field.values.first)
      assert custom_field.find_values_mapped_to_standard(standard_field.values.last).include?(custom_field.values.last)
      assert custom_field.find_values_mapped_to_standard("b").include?(custom_field.values.last)
    end

    test "find_priority_value_mapped_to_standard" do
      standard_field = FieldMapper::Standard::Field.new(:foo, type: String)
      standard_field.value("a")
      standard_field.value("b")
      custom_field = FieldMapper::Custom::Field.new(:bar, standard_field: standard_field)
      custom_field.value("A", standard: "a")
      custom_field.value("AA", standard: "a", priority: true)
      custom_field.value("B", standard: "b")
      assert custom_field.find_priority_value_mapped_to_standard("a") == custom_field.values[1]
    end

    test "flip_strategy (default is :compute)" do
      standard_field = FieldMapper::Standard::Field.new(:foo, type: String)
      custom_field = FieldMapper::Custom::Field.new(:bar, standard_field: standard_field)
      assert custom_field.flip_strategy(:custom_to_standard) == :compute
      assert custom_field.flip_strategy(:standard_to_custom) == :compute
    end

    test "flip_strategy (default with allowed values is :find)" do
      standard_field = FieldMapper::Standard::Field.new(:foo, type: String)
      standard_field.value("a")
      custom_field = FieldMapper::Custom::Field.new(:bar, standard_field: standard_field)
      custom_field.value("A", standard: "a")
      assert custom_field.flip_strategy(:custom_to_standard) == :find
      assert custom_field.flip_strategy(:standard_to_custom) == :find
    end

    test "flip_strategy (with allowed values and flipper overrides is :compute)" do
      standard_field = FieldMapper::Standard::Field.new(:foo, type: String)
      standard_field.value("a")
      custom_field = FieldMapper::Custom::Field.new(
        :bar,
        standard_field: standard_field,
        custom_to_standard: -> (value, params: {}) { "override" },
        standard_to_custom: -> (value, params: {}) { "override" },
      )
      custom_field.value("A", standard: "a")
      assert custom_field.flip_strategy(:custom_to_standard) == :compute
      assert custom_field.flip_strategy(:standard_to_custom) == :compute
    end
  end
end
