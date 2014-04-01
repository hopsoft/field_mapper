require_relative "../test_helper"

module Custom
  class ValueTest < MicroTest::Test

    before do
      standard_field = FieldMapper::Standard::Field.new(:foo, type: String)
      @custom_field = FieldMapper::Custom::Field.new(:bar, standard_field: standard_field)
    end

    test "constructor requires standar_field when standard_value is set" do
      begin
        custom_field = FieldMapper::Custom::Field.new(:bar, type: Integer)
        FieldMapper::Custom::Value.new(1, field: custom_field, standard_value: 1)
      rescue StandardFieldNotFound => e
        error = e
      end
      assert error.present?
    end

    test "constructor ensures standard_value exists" do
      begin
        FieldMapper::Custom::Value.new("a", field: @custom_field, standard_value: "a")
      rescue StandardValueNotFound => e
        error = e
      end
      assert error.present?
    end

    test "constructor maps values" do
      @custom_field.standard_field.value("a")
      value = FieldMapper::Custom::Value.new("a", field: @custom_field, standard_value: "a")
      assert value.value == value.standard_value.value
    end

    test "constructor sets priority" do
      @custom_field.standard_field.value("a")
      value = FieldMapper::Custom::Value.new("a", field: @custom_field, standard_value: "a", priority: true)
      assert value.priority
    end

  end
end
