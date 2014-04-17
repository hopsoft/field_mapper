require_relative "../test_helper"
require_relative "plat_example"
require_relative "../custom/plat_example"
require_relative "../custom/plat_example_alt"

module Standard
  class ConverterTest < MicroTest::Test

    before do
      @standard = Standard::PlatExample.new
      @converter = FieldMapper::Standard::Converter.new(@standard)
    end

    test "convert_to (basic)" do
      @standard.name = "foobar"
      custom = @converter.convert_to(Custom::PlatExample)
      assert custom.name == "foobar"
    end

    test "convert_to (find strategy)" do
      @standard.score = 3
      custom = @converter.convert_to(Custom::PlatExample)
      assert custom.rating == "C"
    end

    test "convert_to (compute strategy)" do
      @standard.name = "Nathan"
      @standard.desc = "This is a test."
      custom = @converter.convert_to(Custom::PlatExample)
      assert custom.desc == "'This is a test.' --Nathan"
    end

    test "convert_to (custom has values but standard does not MATCH)" do
      @standard.desc = "Male"
      custom = @converter.convert_to(Custom::PlatExampleAlt)
      assert custom.gender == "Male"
    end

    test "convert_to (custom has values but standard does not NO MATCH)" do
      @standard.desc = "Bunk"
      custom = @converter.convert_to(Custom::PlatExampleAlt)
      assert custom.gender.nil?
    end

    test "convert_to (standard has values but custom does not)" do
      @standard.day = "Tuesday"
      custom = @converter.convert_to(Custom::PlatExampleAlt)
      assert custom.day == "Tuesday"
    end

    test "convert_to (multiple selected list values)" do
      @standard.letters = ["a", "c"]
      custom = @converter.convert_to(Custom::PlatExample)
      assert custom.characters = ["X", "Z"]
    end

    test "convert_to (with PlatList values)" do
      a = Standard::PlatExample.new(name: "a", score: 1)
      b = Standard::PlatExample.new(name: "b", score: 2)
      @standard.children = [a, b]
      converter = FieldMapper::Standard::Converter.new(@standard)
      custom = converter.convert_to(Custom::PlatExample)

      assert custom.child_plats.first.name == "a"
      assert custom.child_plats.first.rating == "A"
      custom_a = FieldMapper::Standard::Converter.new(a).convert_to(Custom::PlatExample)
      assert custom.child_plats.first.to_hash.merge(_node_id: nil) == custom_a.to_hash.merge(_node_id: nil)

      assert custom.child_plats.last.name == "b"
      assert custom.child_plats.last.rating == "B"
      custom_b = FieldMapper::Standard::Converter.new(b).convert_to(Custom::PlatExample)
      assert custom.child_plats.last.to_hash.merge(_node_id: nil) == custom_b.to_hash.merge(_node_id: nil)
    end

    test "convert_to (with PlatList value)" do
      parent = Standard::PlatExample.new(name: "parent", score: 1)
      @standard.parent = parent
      converter = FieldMapper::Standard::Converter.new(@standard)
      custom = converter.convert_to(Custom::PlatExample)

      assert custom.parent_plat.name == "parent"
      assert custom.parent_plat.rating == "A"
      custom_parent = FieldMapper::Standard::Converter.new(parent).convert_to(Custom::PlatExample)
      assert custom.parent_plat.to_hash.merge(_node_id: nil) == custom_parent.to_hash.merge(_node_id: nil)
    end

    test "convert_to (different datatype)" do
      @standard.timestamp = Time.now
      custom = @converter.convert_to(Custom::PlatExample)
      assert custom.time == @standard.timestamp.strftime("%Y-%m-%m")
    end

    test "placeholder" do
      assert @standard.class.fields[:name].placeholder == "TYPE YOUR NAME"
    end

  end
end
