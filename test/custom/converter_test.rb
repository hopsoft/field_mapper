require_relative "../test_helper"
require_relative "plat_example"
require_relative "plat_example_alt"

module Custom
  class ConverterTest < MicroTest::Test

    before do
      @custom = Custom::PlatExample.new
      @converter = FieldMapper::Custom::Converter.new(@custom)
    end

    test "convert_to_standard (basic)" do
      @custom.name = "foobar"
      standard = @converter.convert_to_standard
      assert standard.name == "foobar"
    end

    test "convert_to_standard (find strategy)" do
      @custom.rating = "C"
      standard = @converter.convert_to_standard
      assert standard.score == 3
    end

    test "convert_to_standard (compute strategy)" do
      @custom.name = "Nathan"
      @custom.desc = "This is a test."
      standard = @converter.convert_to_standard
      assert standard.desc == "Nathan says, 'This is a test.'"
    end

    test "convert_to_standard (compute strategy with values)" do
      @custom.name = "Nathan"
      @custom.color = "red"
      standard = @converter.convert_to_standard
      assert standard.color == "blue"
    end

    test "convert_to_standard (compute strategy with values alt)" do
      @custom.color = "red"
      standard = @converter.convert_to_standard
      assert standard.color == "orangered"
    end

    test "convert_to_standard (custom has values but standard does not)" do
      custom = Custom::PlatExampleAlt.new
      converter = FieldMapper::Custom::Converter.new(custom)
      custom.gender = "Male"
      standard = converter.convert_to_standard
      assert standard.desc == "Male"
    end

    test "convert_to_standard (standard has values but custom does not MATCH)" do
      custom = Custom::PlatExampleAlt.new
      converter = FieldMapper::Custom::Converter.new(custom)
      custom.day = "Tuesday"
      standard = converter.convert_to_standard
      assert standard.day == "Tuesday"
    end

    test "convert_to_standard (standard has values but custom does not NO MATCH)" do
      custom = Custom::PlatExampleAlt.new
      converter = FieldMapper::Custom::Converter.new(custom)
      custom.day = "Bunk"
      standard = converter.convert_to_standard
      assert standard.day.nil?
    end

    test "convert_to" do
      @custom.name = "foo"
      @custom.rating = "C"
      @custom.color = "green"
      custom = @converter.convert_to(Custom::PlatExampleAlt)
      assert custom.name == "foo"
      assert custom.fonzie == "AAA"
      assert custom.rbg == "G"
    end

    test "convert_to (loaded values)" do
      @custom.color = "realblue"
      custom = @converter.convert_to(Custom::PlatExampleAlt)
      assert custom.colour == "blue"
    end

    test "convert_to_standard (with PlatList values)" do
      a = Custom::PlatExample.new(name: "a", rating: "A")
      b = Custom::PlatExample.new(name: "b", rating: "B")
      @custom.child_plats = [a, b]
      converter = FieldMapper::Custom::Converter.new(@custom)
      standard = converter.convert_to_standard

      assert standard.children.first.name == "a"
      assert standard.children.first.score == 1
      standard_a = FieldMapper::Custom::Converter.new(a).convert_to_standard
      assert standard.children.first.to_hash.merge(_node_id: nil) == standard_a.to_hash.merge(_node_id: nil)

      assert standard.children.last.name == "b"
      assert standard.children.last.score == 2
      standard_b = FieldMapper::Custom::Converter.new(b).convert_to_standard
      assert standard.children.last.to_hash.merge(_node_id: nil) == standard_b.to_hash.merge(_node_id: nil)
    end

    test "convert_to_standard (with PlatList value)" do
      parent = Custom::PlatExample.new(name: "parent", rating: "A")
      @custom.parent_plat = parent
      converter = FieldMapper::Custom::Converter.new(@custom)
      standard = converter.convert_to_standard

      assert standard.parent.name == "parent"
      assert standard.parent.score == 1
      standard_parent = FieldMapper::Custom::Converter.new(parent).convert_to_standard
      assert standard.parent.to_hash.merge(_node_id: nil) == standard_parent.to_hash.merge(_node_id: nil)
    end

    test "convert_to (multiple selected list values)" do
      @custom.characters = ["X", "Z"]
      converter = FieldMapper::Custom::Converter.new(@custom)
      standard = converter.convert_to_standard
      assert standard.letters = ["a", "c"]
    end

  end
end
