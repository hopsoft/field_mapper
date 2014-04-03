require_relative "../test_helper"
require_relative "../standard/plat_example"

class PlatTest < MicroTest::Test

  test "initialize fails with instance type" do
    begin
      FieldMapper::Types::Plat.new("")
    rescue FieldMapper::InvalidPlatType => error
    end
    assert !error.nil?
  end

  test "initialize fails with non plat type" do
    begin
      FieldMapper::Types::Plat.new(String)
    rescue FieldMapper::InvalidPlatType => error
    end
    assert !error.nil?
  end

  test "initialize succeeds with plat type" do
    begin
      FieldMapper::Types::Plat.new(Standard::PlatExample)
    rescue FieldMapper::InvalidPlatType => error
    end
    assert error.nil?
  end

  test "[] construction" do
    begin
      FieldMapper::Types::Plat[Standard::PlatExample]
    rescue FieldMapper::InvalidPlatType => error
    end
    assert error.nil?
  end

end
