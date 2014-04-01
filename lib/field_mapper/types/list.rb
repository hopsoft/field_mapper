require_relative "../standard/plat"
require_relative "../marshaller"

module FieldMapper
  module Types

    class List
      extend Forwardable

      ALLOWED_TYPES = [
        String,
        Integer,
        Float,
        FieldMapper::Standard::Plat
      ]

      attr_reader :type

      class << self

        def [](type)
          List.new(type)
        end

      end

      def initialize(type, values=[])
        raise InvalidListType unless valid_type?(type)
        @type = type
      end

      def name
        self.class.name
      end

      def plat_list?
        type.ancestors.include?(FieldMapper::Standard::Plat)
      end

      def valid?(list)
        return true if list.empty?
        types = list.map{ |v| v.class }.uniq
        return false if types.length > 1
        types.first.ancestors.include? type
      end

      private

      def valid_type?(type)
        return false if type.class != Class
        !(type.ancestors & ALLOWED_TYPES).empty?
      end

    end

  end
end

