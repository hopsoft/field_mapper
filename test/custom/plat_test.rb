require_relative "../test_helper"
require_relative "plat_example"
require_relative "plat_example_inherited"

module Custom
  class PlatTest < PryTest::Test

    before do
      @class = Custom::PlatExample
      @instance = Custom::PlatExample.new
    end

    test "set_standard" do
      assert @class.standard_plat == Standard::PlatExample
    end

    test "field mapping" do
      assert @class.find_field(:name).standard_field == @class.standard_plat.find_field(:name)
    end

    test "field access by standard_name" do
      @instance.standard_name[:score] = "A"
      assert @instance.standard_name[:score] == "A"
      assert @instance[:rating] == "A"
    end

    test "standard_keys_to_custom_keys" do
      standard_keyed_params = { score: "A" }
      custom_params = Custom::PlatExample.standard_keys_to_custom_keys(standard_keyed_params)
      assert custom_params[:rating] == "A"
    end

    test "standard_keys_to_custom_keys recursive" do
      standard_keyed_params = {
        score: "A",
        parent: { score: "B" },
        children: [
          { score: "A" },
          { score: "B" },
          { score: "C" }
        ]
      }

      custom_params = Custom::PlatExample.standard_keys_to_custom_keys(standard_keyed_params)
      assert custom_params == {
        rating: "A",
        parent_plat: { rating: "B" },
        child_plats: [
          { rating: "A" },
          { rating: "B" },
          { rating: "C"}
        ]
      }
    end

    test "new_from_standard_keyed_params" do
      standard_keyed_params = { score: "A" }
      instance = Custom::PlatExample.new_from_standard_keyed_params(standard_keyed_params)
      assert instance[:rating] == "A"
    end

    test "field mapping with value mappings" do
      custom_field = @class.find_field(:color)
      standard_field = @class.standard_plat.find_field(:color)
      assert custom_field.standard_field == standard_field
      assert custom_field.find_value("blue").standard_value == standard_field.find_value("aliceblue")
      assert custom_field.find_value("green").standard_value == standard_field.find_value("lawngreen")
      assert custom_field.find_value("red").standard_value == standard_field.find_value("orangered")
    end

    test "field mapping with value mappings (diff names)" do
      custom_field = @class.find_field(:painter)
      standard_field = @class.standard_plat.find_field(:artist)
      assert custom_field.standard_field == standard_field
      assert custom_field.find_value("Leonardo").standard_value == standard_field.find_value("Leonardo Da Vinci")
    end

    test "field mapping with value mappings (diff types)" do
      custom_field = @class.find_field(:rating)
      standard_field = @class.standard_plat.find_field(:score)
      assert custom_field.standard_field == standard_field
      assert custom_field.find_value("A").standard_value == standard_field.find_value(1)
      assert custom_field.find_value("B").standard_value == standard_field.find_value(2)
      assert custom_field.find_value("C").standard_value == standard_field.find_value(3)
    end

    test "find_mapped_fields" do
      standard_field = @class.standard_plat.find_field(:artist)
      custom_field = @class.find_field(:painter)
      assert @class.find_mapped_fields(standard_field).include?(custom_field)
    end

    test "to_hash" do
      @instance.parent_plat = Custom::PlatExample.new
      @instance.child_plats << Custom::PlatExampleAlt.new
      @instance.child_plats << Custom::PlatExampleAlt.new
      assert @instance.to_hash == {
        "_node_id"  => @instance.object_id,
        "_flat"       => false,
        "name"        => nil,
        "desc"        => nil,
        "rating"      => nil,
        "color"       => nil,
        "painter"     => nil,
        "characters"  => nil,
        "time"        => nil,
        "parent_plat" => {
          "_node_id"  => @instance.parent_plat.object_id,
          "_flat"       => false,
          "name"        => nil,
          "desc"        => nil,
          "rating"      => nil,
          "color"       => nil,
          "painter"     => nil,
          "characters"  => nil,
          "time"        => nil,
          "parent_plat" => nil,
          "child_plats" => []
        },
        "child_plats" => [
          {
            "_node_id" => @instance.child_plats.first.object_id,
            "_flat"       => false,
            "name"       => nil,
            "gender"     => nil,
            "day"        => nil,
            "fonzie"     => nil,
            "rbg"        => nil,
            "colour"     => nil
          },
         {
            "_node_id" => @instance.child_plats.last.object_id,
            "_flat"       => false,
            "name"       => nil,
            "gender"     => nil,
            "day"        => nil,
            "fonzie"     => nil,
            "rbg"        => nil,
            "colour"     => nil
          }
        ]
      }
    end

    test "placeholder" do
      assert @instance.class.fields[:name].placeholder == "TYPE YOUR NAME"
    end

    test "inhertied class can overwrite fields with different names" do
      inherited_plat = Custom::PlatExampleInherited.new

      begin
        inherited_plat.rating
      rescue FieldMapper::FieldNotDefined => _
        assert true
      end

      begin
        inherited_plat.star_rating
        assert true
      rescue FieldMapper::FieldNotDefined => _
        assert false
      end
    end

    test "inherited class can set new fields" do
      inherited_plat = Custom::PlatExampleInherited.new(
        id: 'testing'
      )

      assert inherited_plat.id.present?
    end

    test "inherited class can change previously defined fields" do
      inherited_plat = Custom::PlatExampleInherited.new

      assert inherited_plat.name == "Inherited"
    end

    #test "basic mapped fields" do
    #  assert false
    #end

  end
end
