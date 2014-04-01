require_relative "../test_helper"

module Standard
  class ValueTest < MicroTest::Test

    test "constructor requires field" do
      begin
        FieldMapper::Standard::Value.new("bar")
      rescue ArgumentError => e
        error = e
      end
      assert error.present?
    end

    test "constructor sets value" do
      field = FieldMapper::Standard::Field.new(:foo, type: String)
      value = FieldMapper::Standard::Value.new("bar", field: field)
      assert value.value == "bar"
    end

    test "constructor type casts value" do
      field = FieldMapper::Standard::Field.new(:foo, type: Integer)
      value = FieldMapper::Standard::Value.new("100", field: field)
      assert value.value == 100
    end

  end
end
