require_relative "plat_example"

module Custom
  class PlatExampleInherited < Custom::PlatExample
    field :id, type: String
    field :name, standard: :name, default: "Inherited"

    field :star_rating, type: String, standard: :score do
      value "*", standard: 1
      value "**", standard: 2
      value "***", standard: 3
    end
  end
end
