require_relative "../test_helper"

module Standard
  class PlatExample < FieldMapper::Standard::Plat

    field :name, type: String
    field :desc, type: String

    field :score, default: 2, type: Integer do
      value 1
      value 2
      value 3
    end

    field :color, type: String do
      load_values File.expand_path("../assets/colors.csv", __FILE__)
    end

    field :camelCase, type: String
    field :PascalCase, type: String

    field :artist, type: String do
      value "Leonardo Da Vinci"
      value "Michelangelo Buonarroti"
      value "Raphael Sanzio"
    end

    field :day, type: String do
      value "Sunday"
      value "Monday"
      value "Tuesday"
      value "Wednesday"
      value "Thursday"
      value "Friday"
      value "Saturday"
    end

    field :letters, type: FieldMapper::Types::List[String], default: ["a", "b"] do
      value "a"
      value "b"
      value "c"
    end

    field :parent, type: FieldMapper::Types::Plat[Standard::PlatExample]
    field :children, type: FieldMapper::Types::List[Standard::PlatExample], default: []

  end
end
