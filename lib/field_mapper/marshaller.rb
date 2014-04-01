require "oj"

module FieldMapper
  module Marshaller

    OPTIONS = {
      indent: 0,
      circular: false,
      class_cache: true,
      escape: :json,
      time: :unix,
      create_id: "natefoo"
    }

    def marshal(value)
      Oj.dump value, OPTIONS
    end

    def unmarshal(value)
      Oj.load value, OPTIONS
    end

  end
end
