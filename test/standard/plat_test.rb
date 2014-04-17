require_relative "../test_helper"
require_relative "plat_example"

module Standard
  class PlatTest < MicroTest::Test

    before do
      @class = Standard::PlatExample
      @instance = Standard::PlatExample.new
    end

    test "values assigned" do
      assert @class.fields[:score].values.length == 3
      assert @class.fields[:score].values[0].value == 1
      assert @class.fields[:score].values[1].value == 2
      assert @class.fields[:score].values[2].value == 3
    end

    test "methods defined" do
      assert @instance.respond_to?(:name)
      assert @instance.respond_to?(:name=)
      assert @instance.respond_to?(:camel_case)
      assert @instance.respond_to?(:camel_case=)
      assert @instance.respond_to?(:pascal_case)
      assert @instance.respond_to?(:pascal_case=)
    end

    test "defaults asigned" do
      assert @instance.score == 2
      assert @instance.letters = ["a", "c"]
    end

    test "constructor (with params)" do
      instance = @class.new(name: "bar", score: 1)
      assert instance.name == "bar"
      assert instance.score == 1
    end

    test "read/write attr using []" do
      @instance[:camelCase] = "as defined"
      assert @instance[:camelCase] == "as defined"

      @instance[:camel_case] = "ruby variant"
      assert @instance[:camel_case] == "ruby variant"
    end

    test "read/write attr using []" do
      @instance.pascal_case = true
      assert @instance.pascal_case
    end

    test "read/write attr using getter/setter" do
      @instance.name = "foobar"
      assert @instance.name == "foobar"
    end

    test "assing multiple values to list field" do
      instance = Standard::PlatExample.new(letters: ["a", "c", 1, true, Object.new])
      assert ["a", "c"] == instance.letters
    end

    test "to_hash with flatten" do
      hash = @instance.to_hash(flatten: true)
      assert hash[:letters] == "[\"a\",\"b\"]"
    end

    test "to_hash with placeholders" do
      assert @instance.to_hash(placeholders: true)[:name] == "TYPE YOUR NAME"
    end

    test "parent & children" do
      parent = Standard::PlatExample.new
      parent_id = parent.object_id
      @instance.parent = parent

      assert @instance.parent.children.empty?
      assert @instance.parent != @instance

      child1 = Standard::PlatExample.new
      child1_id = child1.object_id
      @instance.children << child1

      child2 = Standard::PlatExample.new
      child2_id = child2.object_id
      @instance.children << child2

      assert @instance.parent.object_id == parent_id
      assert @instance.children.first.object_id == child1_id
      assert @instance.children.last.object_id == child2_id
      assert @instance.parent.children.empty?
    end

    test "to_hash" do
      parent = Standard::PlatExample.new(children: [@instance])
      @instance.parent = parent

      child1 = Standard::PlatExample.new(parent: @instance)
      @instance.children << child1

      child2 = Standard::PlatExample.new(parent: @instance)
      @instance.children << child2

      expected = {
        "_node_id" => @instance.object_id,
        "_flat"      => false,
        "name"       => nil,
        "desc"       => nil,
        "score"      => 2,
        "color"      => nil,
        "camelCase"  => nil,
        "PascalCase" => nil,
        "artist"     => nil,
        "day"        => nil,
        "letters"    => ["a", "b"],
        "timestamp"  => nil,
        "parent"=>{
           "_node_id" => parent.object_id,
           "_flat"      => false,
           "name"       => nil,
           "desc"       => nil,
           "score"      => 2,
           "color"      => nil,
           "camelCase"  => nil,
           "PascalCase" => nil,
           "artist"     => nil,
           "day"        => nil,
           "letters"    => ["a", "b"],
           "timestamp"  => nil,
           "parent"     => nil,
           "children"   => [@instance.object_id]
        },
        "children"=>[
          {
           "_node_id" => child1.object_id,
           "_flat"      => false,
           "name"       => nil,
           "desc"       => nil,
           "score"      => 2,
           "color"      => nil,
           "camelCase"  => nil,
           "PascalCase" => nil,
           "artist"     => nil,
           "day"        => nil,
           "letters"    => ["a", "b"],
           "timestamp"  => nil,
           "parent"     => @instance.object_id,
           "children"   => []
          },
          {
           "_node_id" => child2.object_id,
           "_flat"      => false,
           "name"       => nil,
           "desc"       => nil,
           "score"      => 2,
           "color"      => nil,
           "camelCase"  => nil,
           "PascalCase" => nil,
           "artist"     => nil,
           "day"        => nil,
           "letters"    => ["a", "b"],
           "timestamp"  => nil,
           "parent"     => @instance.object_id,
           "children"   => []
          }
        ]
      }

      actual = @instance.to_hash
      assert actual == expected
    end

    test "to_hash flatten" do
      parent = Standard::PlatExample.new(children: [@instance])
      @instance.parent = parent

      child1 = Standard::PlatExample.new(parent: @instance)
      @instance.children << child1

      child2 = Standard::PlatExample.new(parent: @instance)
      @instance.children << child2

      expected = {
        "_node_id"   => @instance.object_id,
        "_flat"      => true,
        "name"       => nil,
        "desc"       => nil,
        "score"      => 2,
        "color"      => nil,
        "camelCase"  => nil,
        "PascalCase" => nil,
        "artist"     => nil,
        "day"        => nil,
        "letters"    => "[\"a\",\"b\"]",
        "timestamp"  => nil,
        "parent"     => "{\"_node_id\":#{parent.object_id},\"_flat\":true,\"name\":null,\"desc\":null,\"score\":2,\"color\":null,\"camelCase\":null,\"PascalCase\":null,\"artist\":null,\"day\":null,\"letters\":\"[\\\"a\\\",\\\"b\\\"]\",\"parent\":null,\"children\":\"[#{@instance.object_id}]\",\"timestamp\":null}",
        "children"   => "[{\"_node_id\":#{child1.object_id},\"_flat\":true,\"name\":null,\"desc\":null,\"score\":2,\"color\":null,\"camelCase\":null,\"PascalCase\":null,\"artist\":null,\"day\":null,\"letters\":\"[\\\"a\\\",\\\"b\\\"]\",\"parent\":#{@instance.object_id},\"children\":[],\"timestamp\":null},{\"_node_id\":#{child2.object_id},\"_flat\":true,\"name\":null,\"desc\":null,\"score\":2,\"color\":null,\"camelCase\":null,\"PascalCase\":null,\"artist\":null,\"day\":null,\"letters\":\"[\\\"a\\\",\\\"b\\\"]\",\"parent\":#{@instance.object_id},\"children\":[],\"timestamp\":null}]"
      }

      actual = @instance.to_hash(flatten: true)
      assert actual[:_flat]
      assert actual == expected
    end

    test "initialize from to_hash (simple)" do
      @instance.name = "foobar"
      @instance.score = 3
      @instance.letters = ["c"]
      hash = @instance.to_hash
      instance = Standard::PlatExample.new(hash)
      assert @instance.to_hash(include_meta: false) == instance.to_hash(include_meta: false)
    end

    test "initialize from to_hash (simple flat)" do
      @instance.name = "foobar"
      @instance.score = 3
      @instance.letters = ["c"]
      hash = @instance.to_hash(flatten: true)
      instance = Standard::PlatExample.new(hash)
      assert @instance.to_hash(include_meta: false) == instance.to_hash(include_meta: false)
    end

    test "initialize from to_hash (parent)" do
      @instance.parent = Standard::PlatExample.new(children: [@instance])
      hash = @instance.to_hash
      instance = Standard::PlatExample.new(hash)
      assert instance.parent.children.length == 1
      assert instance.parent.children.first == instance
    end

    test "initialize from to_hash flattened (parent)" do
      @instance.parent = Standard::PlatExample.new(children: [@instance])
      hash = @instance.to_hash(flatten: true)
      instance = Standard::PlatExample.new(hash)
      assert instance.parent.children.length == 1
      assert instance.parent.children.first == instance
    end

    test "initialize from to_hash (children)" do
      child1 = Standard::PlatExample.new(parent: @instance)
      @instance.children << child1

      child2 = Standard::PlatExample.new(parent: @instance)
      @instance.children << child2

      hash = @instance.to_hash
      instance = Standard::PlatExample.new(hash)

      assert instance.children.length == 2
      instance.children.each do |child|
        assert child.parent == instance
      end
    end

    test "initialize from to_hash flattened (children)" do
      child1 = Standard::PlatExample.new(parent: @instance)
      @instance.children << child1

      child2 = Standard::PlatExample.new(parent: @instance)
      @instance.children << child2

      hash = @instance.to_hash(flatten: true)
      instance = Standard::PlatExample.new(hash)

      assert instance.children.length == 2
      instance.children.each do |child|
        assert child.parent == instance
      end
    end

    test "initialize from to_hash (parent & children)" do
      @instance.parent = Standard::PlatExample.new(children: [@instance])

      child1 = Standard::PlatExample.new(parent: @instance)
      @instance.children << child1

      child2 = Standard::PlatExample.new(parent: @instance)
      @instance.children << child2

      hash = @instance.to_hash
      instance = Standard::PlatExample.new(hash)

      assert instance.parent.children.length == 1
      assert instance.parent.children.first == instance

      assert instance.children.length == 2
      instance.children.each do |child|
        assert child.parent == instance
      end
    end

    test "initialize from to_hash flattened (parent & children)" do
      @instance.parent = Standard::PlatExample.new(children: [@instance])

      child1 = Standard::PlatExample.new(parent: @instance)
      @instance.children << child1

      child2 = Standard::PlatExample.new(parent: @instance)
      @instance.children << child2

      hash = @instance.to_hash(flatten: true)
      instance = Standard::PlatExample.new(hash)

      assert instance.parent.children.length == 1
      assert instance.parent.children.first == instance

      assert instance.children.length == 2
      instance.children.each do |child|
        assert child.parent == instance
      end
    end

  end
end
