require_relative "../test_helper"

class BooleanTest < PryTest::Test
  Boolean = FieldMapper::Types::Boolean

  test "parse nil" do
    assert Boolean.parse(nil) == false
  end

  test "parse 0" do
    assert Boolean.parse(0) == false
  end

  test "parse f" do
    assert Boolean.parse("f") == false
  end

  test "parse F" do
    assert Boolean.parse("F") == false
  end

  test "parse false" do
    assert Boolean.parse("false") == false
  end

  test "parse FALSE" do
    assert Boolean.parse("FALSE") == false
  end

  test "parse FaLsE" do
    assert Boolean.parse("FaLsE") == false
  end

  test "parse actual false" do
    assert Boolean.parse(false) == false
  end

  test "parse n" do
    assert Boolean.parse("n") == false
  end

  test "parse N" do
    assert Boolean.parse("N") == false
  end

  test "parse no" do
    assert Boolean.parse("no") == false
  end

  test "parse NO" do
    assert Boolean.parse("NO") == false
  end

  test "parse No" do
    assert Boolean.parse("No") == false
  end

  test "parse t" do
    assert Boolean.parse("t")
  end

  test "parse true" do
    assert Boolean.parse("true")
  end

  test "parse actual true" do
    assert Boolean.parse(true)
  end

  test "parse random string" do
    assert Boolean.parse("jfdkhjwe")
  end

  test "parse random number" do
    assert Boolean.parse(7482397)
  end
end
