require_relative "test_helper"

class ReadmeTest < MicroTest::Test

  test "readme examples" do

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

    class FacebookUser < FieldMapper::Custom::Plat
      set_standard StandardUser # note we set the standard

      # mapped fields
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
      field :gender,    standard: :gender do
        # mapped values
        value "female", standard: "F"
        value "male",   standard: "M"
      end
      field :net_worth, standard: :net_worth
      field :friends,   standard: :friends, type: FieldMapper::Types::List[FacebookUser], default: []
      # not all custom fields are required to map to a standard
      field :birthday,  type: Time
    end

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

      def after_convert(from: nil, to: nil)
        if from.respond_to? :friends
          self.followers_count = from.friends.length
        end
      end
    end

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

    converter = FieldMapper::Custom::Converter.new(zuck)
    standard_zuck = converter.convert_to_standard

    $NATE = true
    converter = FieldMapper::Custom::Converter.new(zuck)
    twitter_zuck = converter.convert_to(TwitterUser)

    converter = FieldMapper::Standard::Converter.new(standard_zuck)
    zuck2 = converter.convert_to(FacebookUser)
    twitter_zuck2 = converter.convert_to(TwitterUser)

    zuck_hash = zuck.to_hash

    assert false
  end

end
