module FieldMapper
  module NameHelper

    def attr_name(value)
      value = value.to_s
      @attr_names ||= {}
      @attr_names[value] ||= begin
        value.
          gsub(/\W/, "_").
          gsub(/[A-Z][A-Z]+/) { |match| "_#{match.downcase}_" }.
          gsub(/[A-Z]/) { |match| "_#{match.downcase}" }.
          gsub(/\A_|_\z/, "")
      end
    end

  end
end
