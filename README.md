# FieldMapper

[![Build Status](https://travis-ci.org/hopsoft/field_mapper.png)](https://travis-ci.org/hopsoft/field_mapper)
[![Coverage Status](https://coveralls.io/repos/hopsoft/field_mapper/badge.png)](https://coveralls.io/r/hopsoft/field_mapper)
[![Dependency Status](https://gemnasium.com/hopsoft/field_mapper.png)](https://gemnasium.com/hopsoft/field_mapper)
[![Code Climate](https://codeclimate.com/github/hopsoft/field_mapper.png)](https://codeclimate.com/github/hopsoft/field_mapper)

## Data mapping & transformation with Ruby

> I know companies that employ 30+ people to manage tasks that this library can handle.

### Uses

- Mapping data between 2 or more formats
- Transforming data with complex rules
- Defining data standards

### Overview

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

## Usage

*__Note:__ The examples below highlight most of the features; though, they are painfully contrived.*

Suppose we want to perform a mapping between Facebook users & Twitter users.

1. Define a standard user class.

    ```ruby
    class StandardUser < FieldMapper::Standard::Plat
      field :name,        type: String
      field :screen_name, type: String
      field :info,        type: String
      field :website,     type: String

      # field with allowed values
      field :gender,      type: String do
        value "F"
        value "M"
      end

      field :age,         type: Integer

      # field with a default value
      field :net_worth,   type: Money, default: 0

      # field that holds a list of plats
      field :friends,     type: FieldMapper::Types::List[StandardUser], default: []
    end
    ```

2. Define a Facebook user class.

    ```ruby
    class FacebookUser < FieldMapper::Custom::Plat
      # note that we set the standard
      set_standard StandardUser

      # fields are mapped to the standard
      field :name,      standard: :name

      # field with complex transformation rules
      field :username,  standard: :screen_name,
        custom_to_standard: -> (value, standard_instance: nil) {
          # value passed is the custom value
          # value returned is the standard value
          "Facebook:#{value.to_s.strip}"
        },
        standard_to_custom: -> (value, standard_instance: nil) {
          # value passed is the standard value
          # value returned is the custom value
          value.to_s.split(/:/).last
        }

      field :bio,       standard: :info
      field :website,   standard: :website

      # field with mapped values
      field :gender,    standard: :gender do
        value "female", standard: "F"
        value "male",   standard: "M"
      end

      field :net_worth, standard: :net_worth
      field :friends,   standard: :friends, type: FieldMapper::Types::List[FacebookUser], default: []

      # not all custom fields are required to map to a standard
      field :birthday,  type: Time
    end
    ```

3. Define a Twitter user class.

    ```ruby
    class TwitterUser < FieldMapper::Custom::Plat
      set_standard StandardUser

      field :name,            standard: :name
      field :screen_name,     standard: :screen_name,
        custom_to_standard: -> (value, standard_instance: nil) {
          "Twitter:#{value.to_s.strip}"
        },
        standard_to_custom: -> (value, standard_instance: nil) {
          value.to_s.split(/:/).last
        }
      field :description,     standard: :info
      field :url,             standard: :website
      field :followers_count, type: Integer

      # callback method that runs after tranformation
      def after_convert(from: nil, to: nil)
        if from.respond_to? :friends
          self.followers_count = from.friends.length
        end
      end
    end
    ```

4. Construct a FacebookUser.

    ```ruby
    zuck = FacebookUser.new(
      name: "Mark Zuckerberg",
      username: "zuck",
      bio: "Creator of Facebook",
      website: "http://www.facebook.com/zuck",
      gender: "male",
      age: 29,
      net_worth: "$29,000,000,000 USD", # value will be cast to a Money
      birthday: "1984-05-14" # value will be cast to a Time
    )

    zuck.friends << FacebookUser.new(name: "Priscilla Chan")
    ```

5. Transform zuck to a StandardUser.

    ```ruby
    converter = FieldMapper::Custom::Converter.new(zuck)
    standard_zuck = converter.convert_to_standard
    ```

6. Transform zuck to a TwitterUser.

    ```ruby
    converter = FieldMapper::Custom::Converter.new(zuck)
    twitter_zuck = converter.convert_to(TwitterUser)
    ```

7. Transform standard_zuck to both.

    ```ruby
    converter = FieldMapper::Standard::Converter.new(standard_zuck)
    zuck_from_standard = converter.convert_to(FacebookUser)
    twitter_zuck_from_standard = converter.convert_to(TwitterUser)
    ```

8. Dump the zuck to a Hash.

    ```ruby
    zuck_hash = zuck.to_hash
    {
      "_node_id"  => 70260402777020,
      "_flat"     => false,
      "name"      => "Mark Zuckerberg",
      "username"  => "zuck",
      "bio"       => "Creator of Facebook",
      "website"   => "http://www.facebook.com/zuck",
      "gender"    => "male",
      "net_worth" => "$29,000,000,000.00 USD",
      "friends"   => [
        {
          "_node_id"  => 70260401841760,
          "_flat"     => false,
          "name"      => "Priscilla Chan",
          "username"  => nil,
          "bio"       => nil,
          "website"   => nil,
          "gender"    => nil,
          "net_worth" => nil,
          "friends"   => [],
          "birthday"  => nil
        }
      ],
      "birthday" => "1984-05-14T06:00:00Z"
    }

    zuck_flat_hash = zuck.to_hash(flatten: true)
    {
      "_node_id"  => 70260402777020,
      "_flat"     => true,
      "name"      => "Mark Zuckerberg",
      "username"  => "zuck",
      "bio"       => "Creator of Facebook",
      "website"   => "http://www.facebook.com/zuck",
      "gender"    => "male",
      "net_worth" => "$29,000,000,000.00 USD",
      "friends"   => "[{\"_node_id\":70260401841760,\"_flat\":true,\"name\":\"Priscilla Chan\",\"username\":null,\"bio\":null,\"website\":null,\"gender\":null,\"net_worth\":null,\"friends\":[],\"birthday\":null}]",
      "birthday"  => "1984-05-14T06:00:00Z"
    }
    ```

9. Reconstruct zuck from a Hash.

    ```ruby
    zuck_from_hash = FacebookUser.new(zuck_hash)
    zuck_from_flat_hash = FacebookUser.new(zuck_flat_hash)
    ```

Dig into [the tests](https://github.com/hopsoft/field_mapper/tree/master/test) to learn more.

