require_relative "../test_helper"
require_relative "../standard/plat_example"

module Custom
  class PlatExample < FieldMapper::Custom::Plat
    set_standard Standard::PlatExample

    field :name, standard: :name
    field :desc, standard: :desc,
      custom_to_standard: -> (value, standard_instance: nil) {
        "#{name} says, '#{value}'"
      },
      standard_to_custom: -> (value, standard_instance: nil) {
        "'#{value}' --#{name}"
      }

    field :rating, type: String, standard: :score do
      value "A", standard: 1
      value "B", standard: 2
      value "C", standard: 3
    end

    field :color, standard: :color,
      # NOTE: as a best practice, do not define flippers on fields with allowed values
      #       only doing it here for testing purposes
      custom_to_standard: -> (value, standard_instance: nil) {
        return "blue" if name == "Nathan"
        case value
        when "blue" then "aliceblue"
        when "realblue" then "blue"
        when "green" then "lawngreen"
        when "red" then "orangered"
        end
      } do
      value "blue", standard: "aliceblue"
      value "realblue", standard: "blue"
      value "green", standard: "lawngreen"
      value "red", standard: "orangered"
    end

    field :painter, standard: :artist do
      value "Leonardo",     standard: "Leonardo Da Vinci", priority: true
      value "Leo",          standard: "Leonardo Da Vinci"
      value "Michelangelo", standard: "Michelangelo Buonarroti"
      value "Raphael",      standard: "Raphael Sanzio"
    end

    field :characters, standard: :letters do
      value "X", standard: "a"
      value "Y", standard: "b"
      value "Z", standard: "c"
    end

    field :parent_plat, type: FieldMapper::Types::Plat[Custom::PlatExample], standard: :parent
    field :child_plats, type: FieldMapper::Types::List[Custom::PlatExample], standard: :children, default: []

  end
end
