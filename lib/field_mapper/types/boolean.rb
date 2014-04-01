module FieldMapper
  module Types

    class Boolean

      def self.parse(value)
        return false if value.nil?
        return false if value.blank? || value.to_s =~ /\A(0|f(alse)?|no?)\z/i
        true
      end

    end

  end
end
