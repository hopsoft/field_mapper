# FieldMapper

[![Build Status](https://travis-ci.org/hopsoft/field_mapper.png)](https://travis-ci.org/hopsoft/field_mapper)
[![Dependency Status](https://gemnasium.com/hopsoft/field_mapper.png)](https://gemnasium.com/hopsoft/field_mapper)
[![Code Climate](https://codeclimate.com/github/hopsoft/field_mapper.png)](https://codeclimate.com/github/hopsoft/field_mapper)

Data mapping & transformation with Ruby

## Uses

- Mapping data between 2 or more formats
- Transforming data with complex rules
- Defining data standards

> I know companies that employ 30+ people to manage tasks that this library can handle.

## Overview

FieldMapper introduces a new term for a model like data structure
to avoid possible confusion with libraries like ActiveRecord.

This new term is: **Plat**

A plat defines the following:

- Fields
- Datatypes
- Mappings
- Transformation rules

Datatype declarations exist to support implicit value casting.
The supported datatypes are:

- String
- Boolean
- Time
- Integer
- Float
- Money
- Plat
- List (of any listed type)

*__Note:__ The examples below highlight most of the features; though, they are painfully contrived."

## Quick Start

Suppose we want to perform a mapping between Facebook users &
Twitter users as represented by their respective APIs.

1. Define a standard user representation.

    ```ruby
    class User < FieldMapper::Standard::Plat
      field :name,        type: String
      field :screen_name, type: String
      field :info,        type: String
      field :website,     type: String
    end
    ```

2. Define a Facebook user representation.

    ```ruby
    class FacebookUser < FieldMapper::Custom::Plat
      set_standard User

      field :name,     standard: name
      field :username, standard: :screen_name
      field :bio,      standard: :info
      field :website,  standard: :website
    end
    ```

3. Define a Twitter user representation.

    ```ruby
    class TwitterUser < FieldMapper::Custom::Plat
      set_standard User

      field :name,        standard: name
      field :screen_name, standard: :screen_name
      field :description, standard: :info
      field :url,         standard: :website
    end
    ```

4. Construct a Facebook user & transform it to a Twitter user.

    ```ruby
    facebook_user = FacebookUser.new(
      name: "Mark Zuckerberg",
      username: "zuck",
      bio: "Creator of Facebook",
      website: "http://www.facebook.com/zuck"
    )

    converter = FieldMapper::Custom::Converter.new(facebook_user)
    twitter_user = converter.convert_to(TwitterUser)
    ```

    *This works going the other direction too.*

## Next Steps

FieldMapper also supports complex transformation rules.
Suppose we wanted to ensure that Facebook user's bios don't include the word "Facebook".

1. Add some transformation rules to the Facebook user.

    ```ruby
    class FacebookUser < FieldMapper::Custom::Plat
      field :name,     standard: name
      field :username, standard: :screen_name
      field :bio,      standard: :info,
        custom_to_standard: -> (value, standard_instance: nil) { value.gsub /facebook/i, "FFFFFUUUUUUUU" },
        standard_to_custom: -> (value, standard_instance: nil) { value.gsub /FFFFFUUUUUUUU/, "Facebook" }
      field :website,  standard: :website
    end
    ```

Note that transformation rules are procs.
The proc should accept a value and a standard instance of the object being transformed.

- `custom_to_standard` - the passed value is custom & you should return the standard value
- `standard_to_custom` - the passed value is standard & you should return the custom value

## Deep Cuts

### Plat types

It's possible to define a field that is a plat type.

```ruby
class User < FieldMapper::Standard::Plat
  field :name,   type: String
  field :parent, type: FieldMapper::Types::Plat[User]
end

parent = User.new(name: "Jon Voight")
child = User.new(name: "Angelina Jolie", parent: parent)
```

This works for custom plats as well... just make sure all the mappings line up.

### List types

It's possible to define a field that is a list type.

```ruby
class User < FieldMapper::Standard::Plat
  field :name,       type: String
  field :child_ages, type: FieldMapper::Types::List[Integer], default: []
  field :children,   type: FieldMapper::Types::List[User], default: []
end

james = User.new(name: "James Haven")
angelina = User.new(name: "Angelina Jolie")
jon = User.new(
  name: "Jon Voight",
  child_ages: [41, 38],
  children: [james, angelina]
)
```

This works for custom plats as well... just make sure all the mappings line up.

### Converting to Hash

Sometimes it's useful to dump a plat to a Hash structure.
Consider the previous example.

```ruby
jon.to_hash # will produce the following data structure

{
  "_node_id"   => 70277977779220,
  "_flat"      => false,
  "name"       => "Jon Voight",
  "child_ages" => [41, 38],
  "children"   => [
    {
      "_node_id"   => 70277980501740,
      "_flat"      => false,
      "name"       => "James Haven",
      "child_ages" => [],
      "children"   => []
    },
    {
      "_node_id"   => 70277980481480,
      "_flat"      => false,
      "name"       => "Angelina Jolie",
      "child_ages" => [],
      "children"   => []
    }
  ]
}
```

You can also flatten the hash.

```ruby
jon.to_hash(flatten: true) # will produce the following data structure

{
  "_node_id"   => 70277977779220,
  "_flat"      => true,
  "name"       => "Jon Voight",
  "child_ages" => "[41,38]",
  "children"   => "[{\"_node_id\":70277980501740,\"_flat\":true,\"name\":\"James Haven\",\"child_ages\":[],\"children\":[]},{\"_node_id\":70277980481480,\"_flat\":true,\"name\":\"Angelina Jolie\",\"child_ages\":[],\"children\":[]}]"
}
```

You can also opt out of generated meta data.

```ruby
jon.to_hash(include_meta: false)
```

Have a look at the tests to better understand what's possible.

