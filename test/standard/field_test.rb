require_relative "../test_helper"
require_relative "plat_example"

module Standard
  class FieldTest < PryTest::Test

    test "constructor requires type" do
      begin
        FieldMapper::Standard::Field.new(:foo)
      rescue FieldMapper::TypeNotSpecified => e
        error = e
      end
      assert error.present?
    end

    test "constructor sets name" do
      field = FieldMapper::Standard::Field.new(:foo, type: String)
      assert field.name == :foo
    end

    test "constructor sets type" do
      field = FieldMapper::Standard::Field.new(:foo, type: String)
      assert field.type == String
    end

    test "constructor sets desc" do
      field = FieldMapper::Standard::Field.new(:foo, type: String, desc: "A description")
      assert field.desc == "A description"
    end

    test "constructor sets default" do
      field = FieldMapper::Standard::Field.new(:foo, type: String, default: "bar")
      assert field.default == "bar"
    end

    test "add value" do
      field = FieldMapper::Standard::Field.new(:foo, type: String)
      field.value("bar")
      assert field.values.first.value == "bar"
    end

    test "load values" do
      field = FieldMapper::Standard::Field.new(:color, type: String)
      field.load_values(File.expand_path("../assets/colors.csv", __FILE__))
      assert field.has_values?
      assert field.values.first.value == "aliceblue"
      assert field.values.last.value == "yellowgreen"
    end

    test "has_values? (false)" do
      field = FieldMapper::Standard::Field.new(:foo, type: String)
      assert !field.has_values?
    end

    test "has_values? (true)" do
      field = FieldMapper::Standard::Field.new(:foo, type: String)
      field.value("bar")
      assert field.has_values?
    end

    test "values (nil)" do
      field = FieldMapper::Standard::Field.new(:foo, type: Integer)
      assert field.values.nil?
    end

    test "values (present)" do
      field = FieldMapper::Standard::Field.new(:foo, type: Integer)
      (1..3).each { |i| field.value(i) }
      assert field.values.present?
      assert field.values.length == 3
    end

    test "find_value (base value)" do
      field = FieldMapper::Standard::Field.new(:foo, type: Integer)
      (1..3).each { |i| field.value(i) }
      assert field.find_value(2) == field.values[1]
    end

    test "find_value (value type)" do
      field = FieldMapper::Standard::Field.new(:foo, type: Integer)
      (1..3).each { |i| field.value(i) }
      assert field.find_value(field.values[1]) == field.values[1]
    end

    test "add value performs type cast" do
      field = FieldMapper::Standard::Field.new(:foo, type: String)
      field.value(:bar)
      assert field.values.first.value == "bar"
    end

    test "cast (String)" do
      field = FieldMapper::Standard::Field.new(:foo, type: String)
      assert field.cast(1) == "1"
    end

    test "cast (Integer)" do
      field = FieldMapper::Standard::Field.new(:foo, type: Integer)
      assert field.cast("1") == 1
    end

    test "cast (Float)" do
      field = FieldMapper::Standard::Field.new(:foo, type: Float)
      assert field.cast("0.1") == 0.1
    end

    test "cast (Time)" do
      field = FieldMapper::Standard::Field.new(:foo, type: Time)
      expected = ActiveSupport::TimeZone["UTC"].parse("2000-01-15").to_time.utc
      assert field.cast("01/15/2000") == expected
    end

    test "cast (Boolean true)" do
      field = FieldMapper::Standard::Field.new(:foo, type: FieldMapper::Types::Boolean)
      assert field.cast(:true) == true
      assert field.cast(:t) == true
      assert field.cast(1) == true
      assert field.cast(:foo) == true
    end

    test "cast (Boolean false)" do
      field = FieldMapper::Standard::Field.new(:foo, type: FieldMapper::Types::Boolean)
      assert field.cast(:false) == false
      assert field.cast(:f) == false
      assert field.cast(:n) == false
      assert field.cast(0) == false
    end

    test "cast (Money USD)" do
      field = FieldMapper::Standard::Field.new(:foo, type: Money)
      assert field.cast("$100.00 USD") == Money.new(100_00, "USD")
    end

    test "cast (Money EUR)" do
      field = FieldMapper::Standard::Field.new(:foo, type: Money)
      assert field.cast("€100.00 EUR") == Money.new(100_00, "EUR")
    end

    test "cast (Money MXN)" do
      field = FieldMapper::Standard::Field.new(:foo, type: Money)
      assert field.cast("$100.00 MXN") == Money.new(100_00, "MXN")
    end

    test "cast (List)" do
      field = FieldMapper::Standard::Field.new(:foo, type: FieldMapper::Types::List[Standard::PlatExample])
      list = []
      list << Standard::PlatExample.new(name: :foo)
      list << Standard::PlatExample.new(name: :bar)
      assert field.cast(list) == list
    end

    test "to_s" do
      field = FieldMapper::Standard::Field.new(:foo, type: String)
      assert field.to_s == field.name
    end
  end
end
