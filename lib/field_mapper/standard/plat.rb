require "digest/md5"
require_relative "../errors"
require_relative "../name_helper"
require_relative "../marshaller"
require_relative "field"

module FieldMapper
  module Standard
    class Plat
      include FieldMapper::NameHelper
      include FieldMapper::Marshaller

      class << self
        include FieldMapper::NameHelper

        def fields
          @fields ||= HashWithIndifferentAccess.new
        end

        def field_names
          @field_names ||= {}
        end

        def field(
          name,
          type: nil,
          desc: nil,
          default: nil,
          &block
        )
          field_names[attr_name(name)] = name

          field = fields[name] = FieldMapper::Standard::Field.new(
            name,
            type: type,
            desc: desc,
            default: default
          )

          field.instance_exec(&block) if block_given?

          define_method(attr_name name) do
            self[name]
          end

          define_method("#{attr_name name}=") do |value|
            self[name] = value
          end
        end

        def find_field(field_name)
          fields[field_names[attr_name(field_name)]]
        end

        def has_plat_fields?
          !plat_fields.empty?
        end

        def plat_fields
          fields.reduce({}) do |memo, keypair|
            if keypair.last.plat_field?
              memo[keypair.first] = keypair.last
            end
            memo
          end
        end

      end

      attr_reader :node_id

      def initialize(params={})
        @node_id = params["_node_id"]
        assign_defaults
        assign_params params
      end

      def scope
        @scope ||= begin
          scope_name = self.class.name.split("::")[0..-2].join("::")
          if scope_name.empty?
            ::Object
          else
            ::Object.const_get(scope_name)
          end
        end
      end

      def after_convert(converted_instance)
        # abstract method to be implemented by subclasses
      end

      def [](field_name)
        raise FieldNotDefined unless field_exists?(field_name)
        instance_variable_get "@#{attr_name(field_name)}"
      end

      def []=(field_name, value)
        field = self.class.find_field(field_name)
        raise FieldNotDefined if field.nil?
        instance_variable_set "@#{attr_name(field_name)}", field.cast(value)
      end

      def to_hash(flatten: false, history: {}, include_meta: true)
        history[object_id] = true
        hash = self.class.fields.values.reduce(HashWithIndifferentAccess.new) do |memo, field|
          name = field.name
          value = instance_variable_get("@#{attr_name(name)}")

          if value.present?
            case field.type.name
            when "FieldMapper::Types::Plat" then
              if value.is_a? FieldMapper::Standard::Plat
                oid = value.object_id
                if history[oid].nil?
                  history[oid] = true
                  value = value.to_hash(flatten: flatten, history: history, include_meta: include_meta)
                  value = marshal(value) if flatten
                else
                  value = oid
                end
              else
                value
              end
            when "FieldMapper::Types::List" then
              if field.plat_list?
                value = value.map do |val|
                  if val.is_a? FieldMapper::Standard::Plat
                    oid = val.object_id
                    if history[oid].nil?
                      history[oid] = true
                      val.to_hash(flatten: flatten, history: history, include_meta: include_meta)
                    else
                      oid
                    end
                  else
                    val
                  end
                end
              end
              value = marshal(value) if flatten
            when "Money" then
              value = value.format(with_currency: true)
            when "Time" then
              value = value.utc.strftime("%Y-%m-%d %H:%M:%S.%L %z")
            end
          end

          memo[name] = value
          memo
        end

        if include_meta
          hash = {
            _node_id: object_id,
            _flat: flatten
          }.merge(hash)
        end

        HashWithIndifferentAccess.new(hash)
      end

      def cache_key
        self.class.name + "-" + Digest::MD5.hexdigest(to_hash.to_s)
      end

      protected

      def plat_values
        self.class.plat_fields.values.reduce([]) do |memo, field|
          value = send(field.name)
          memo << value if field.plat?
          memo.concat value if field.plat_list?
          memo
        end
      end

      def descendant_plats(history: {})
        return {} if history[object_id]
        history[object_id] = true
        plats = {}
        plats[self.node_id || self.object_id] = self

        plat_values.each do |plat|
          if plat.is_a? FieldMapper::Standard::Plat
            plats[plat.node_id || plat.object_id] = plat
            plats.merge! plat.descendant_plats(history: history)
          end
        end

        plats
      end

      def pending_assignments
        @pending_assignments ||= []
      end

      def all_pending_assignments
        descendant_plats.values.reduce([]) do |memo, plat|
          memo.concat plat.pending_assignments
        end
      end

      def field_exists?(field_name)
        !!self.class.field_names[attr_name(field_name)]
      end

      def assign_defaults
        self.class.fields.each do |name, field|
          if !field.default.nil?
            value = field.default
            value = value.clone rescue value
            instance_variable_set "@#{attr_name(field.name)}", field.cast(value)
          end
        end
      end

      def assign_params(params)
        pending_assignments.clear
        params.each do |name, value|
          field = self.class.fields[name]
          next if field.nil?
          value = field.cast(value)
          next if value.nil?
          next if field.list? && value.compact.empty?
          assign_param name, value
          add_pending_assignment field, value
        end

        apply_pending_assignments descendant_plats
      end

      def assign_param(name, value)
        instance_variable_set "@#{attr_name(name)}", value
      end

      def add_pending_assignment(field, value)
        if field.plat? && value.is_a?(Numeric)
          add_pending_assignment_for_plat field, value
        end

        if field.plat_list? && !value.nil?
          add_pending_assignment_for_plat_list field, value
        end
      end

      def add_pending_assignment_for_plat(field, value)
        pending_assignments << lambda do |descendant_plats|
          if value.is_a?(Numeric)
            plat = descendant_plats[value]
            assign_param field.name, plat unless plat.nil?
          end
        end
      end

      def add_pending_assignment_for_plat_list(field, value)
        pending_assignments << lambda do |descendant_plats|
          list = value.reduce([]) do |memo, val|
            if val.is_a?(Numeric)
              plat = descendant_plats[val]
              memo << (plat ? plat : val)
            else
              memo << val
            end
            memo
          end
          assign_param field.name, list
        end
      end

      def apply_pending_assignments(descendant_plats)
        all_pending_assignments.each do |assignment|
          assignment.call descendant_plats
        end
      end

    end
  end
end
