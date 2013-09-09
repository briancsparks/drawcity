
require './item.rb'

module Gv

  module Graph
    def self.included(child)
      child.extend ClassMethods
    end

    def to_s
      self.class.to_s
    end

    module ClassMethods
      def metaclass; class << self; self; end; end

      # =============================================================
      # Create a mod_type.
      #
      def mod_type(type_sym, type_options = {})
        @mod_types ||= {}

        # Create a new class for the type, derived from Gv::Item
        cl = Class.new do
          include Gv::Item
          @type_options = type_options

          class << self
            attr_accessor :type_options
          end
        end

        # Store the newly created class so we can instantiate it when 
        # we want a new instance of this module type
        @mod_types[type_sym] = cl

        # Create a method so a class can add a mod_type to itself
        metaclass.instance_eval do
          define_method(type_sym) do |sym, name, options = {}|
            @mods ||= {}
            @mods[sym] = @mod_types[type_sym].new sym, name, [], options
          end
        end

      end

      # =============================================================
      # Create a flow_type
      #
      def flow_type(type_sym, type_options = {})
        @flow_type ||= {}

        # Create a new class for the type, derived from Gv::Item
        cl = Class.new do
          include Gv::Item
          @type_options = type_options

          class << self
            attr_accessor :type_options
          end
        end

        # Store the newly created class so we can instantiate it when 
        # we want a new instance of this flow type
        @flow_type[type_sym] = cl

        # Create a method so a class can add a flow_type to itself
        metaclass.instance_eval do
          define_method(type_sym) do |sym, name, mods, options = {}|
            @flows ||= {}
            @flows[sym] = @flow_type[type_sym].new sym, name, mods, options
          end
        end

      end

      # =============================================================
      # Create an action
      #
      def action(name_sym, &blk)

        klass = Class.new do
          def initialize(action, name_sym)
            @action, @name_sym = action, name_sym
          end

          def control_flow(sym, name, mods, options={})
            @action.control_flow(sym, name, mods, options.merge({action: @name_sym}))
          end

          def data_flow(sym, name, mods, options={})
            @action.data_flow(sym, name, mods, options.merge({action: @name_sym}))
          end

          def signal_flow(sym, name, mods, options={})
            @action.signal_flow(sym, name, mods, options.merge({action: @name_sym}))
          end
        end

        blk.call klass.new(self, name_sym)
      end

      def to_s
        msg = []
        msg.push "digraph {"
        msg.push("" + @mods.map do |k,v|
            v.render
          end.join("\n"))

        msg.push("" + @flows.map do |k,v|
            v.render
          end.join("\n")) if !@flows.nil?

        msg.push "}"
      end

    end

  end

end
