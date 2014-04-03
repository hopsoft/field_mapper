require_relative "../test_helper"
require_relative "../standard/plat_example"

class ListTest < MicroTest::Test

  test "initialize fails with instance type" do
    begin
      FieldMapper::Types::List.new("")
    rescue FieldMapper::InvalidListType => error
    end
    assert !error.nil?
  end

  test "initialize fails with invalid type" do
    begin
      FieldMapper::Types::List.new(Object)
    rescue FieldMapper::InvalidListType => error
    end
    assert !error.nil?
  end

  test "initialize succeeds with String type" do
    assert FieldMapper::Types::List.new(String)
  end

  test "initialize succeeds with Integer type" do
    assert FieldMapper::Types::List.new(Integer)
  end

  test "initialize succeeds with Float type" do
    assert FieldMapper::Types::List.new(Float)
  end

  test "initialize succeeds with Plat type" do
    assert FieldMapper::Types::List.new(Standard::PlatExample)
  end

  test "name" do
    type = FieldMapper::Types::List.new(Standard::PlatExample)
    assert type.name == "FieldMapper::Types::List"
  end

  test "plat_list?" do
    assert FieldMapper::Types::List.new(Standard::PlatExample).plat_list?
    assert !FieldMapper::Types::List.new(String).plat_list?
  end

  test "valid? with integer" do
    type = FieldMapper::Types::List.new(Integer)
    assert type.valid?([1,2,3])
    assert !type.valid?([1,2,true])
  end

  test "valid? with float" do
    type = FieldMapper::Types::List.new(Float)
    assert type.valid?([0.1,0.2,0.3])
    assert !type.valid?([0.1,0.2,true])
  end

  test "valid? with string" do
    type = FieldMapper::Types::List.new(String)
    assert type.valid?(["a", "b", "c"])
    assert !type.valid?(["a", "b", true])
  end

  test "[] construction" do
    assert FieldMapper::Types::List[Standard::PlatExample]
    assert FieldMapper::Types::List[String]
  end

end
