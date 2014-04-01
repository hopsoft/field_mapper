require_relative "../test_helper"
require_relative "../standard/plat_example"

module Custom
  class PlatExampleAlt < FieldMapper::Custom::Plat
    set_standard Standard::PlatExample

    field :name, standard: :name

    field :gender, standard: :desc do
      value "Male"
      value "Female"
    end

    field :day, standard: :day

    field :fonzie, type: String, standard: :score do
      value "A", standard: 1
      value "AA", standard: 2
      value "AAA", standard: 3
    end

    field :rbg, standard: :color do
      value "R", standard: "orangered"
      value "G", standard: "lawngreen"
      value "B", standard: "aliceblue"
    end

    field :colour, standard: :color do
      load_values File.expand_path("../assets/colors.csv", __FILE__)
    end

  end
end
