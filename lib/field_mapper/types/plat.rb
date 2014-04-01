require_relative "../standard/plat"

module FieldMapper
  module Types

    class Plat
      extend Forwardable

      attr_reader :type

      class << self

        def [](type)
          Plat.new(type)
        end

      end

      def initialize(type, values=[])
        if type.class != Class || !type.ancestors.include?(FieldMapper::Standard::Plat)
          raise InvalidPlatType
        end

        @type = type
      end

      def name
        self.class.name
      end

    end

  end
end

