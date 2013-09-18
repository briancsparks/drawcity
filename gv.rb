
require File.join(File.dirname(__FILE__), 'item.rb')

module Gv

  module Graph
    def self.included(child)
      child.extend ClassMethods
    end

    def render(spec)
      self.class.render(spec)
    end

    module ClassMethods
      def metaclass; class << self; self; end; end

      # =============================================================
      # Create a mod_type.
      #
      # For example:
      #   mod_type    :service, color: 'blue', penwidth: 3, shape: 'oval'
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
      def action(name, &blk)
        name = name.to_s

        klass = Class.new do
          def initialize(action, name)
            @action, @name = action, name
          end

          def control_flow(sym, name, mods, options={})
            @action.control_flow(sym, name, mods, options.merge({action: @name}))
          end

          def data_flow(sym, name, mods, options={})
            @action.data_flow(sym, name, mods, options.merge({action: @name}))
          end

          def signal_flow(sym, name, mods, options={})
            @action.signal_flow(sym, name, mods, options.merge({action: @name}))
          end

          def action(name, &blk)
            @action.action("#{@name}:#{name}", &blk)
          end
        end

        blk.call klass.new(self, name)
      end

      def render(spec)
        #flow_name = 'print:get_pcl:get_png'
        involved_mods = @flows.map do |k, flow|
          flow.involved(spec)
        end.flatten.uniq

        mods_by_rank = []
        @mods.each do |mod_name, mod|
          rank = mod.rank || 99
          mods_by_rank[rank] ||= {}
          mods_by_rank[rank][mod_name] = mod
        end

        msg = []
        msg.push "digraph {"
        msg.push "  rankdir=TB;"

        mods_by_rank.each do |mods|
          if !mods.nil?
            msg.push("{ rank=same;")
            msg.push("" + mods.map do |mod_name, mod|
              mod.render invis: !involved_mods.include?(mod_name)
            end.join("\n"))
            msg.push("}")
          end
        end

        msg.push "\n\n"

        msg.push("" + @flows.map do |k, flow|
            flow.render invis: flow.involved(spec).empty?
          end.join("\n")) if !@flows.nil?

        msg.push "}"
      end

    end

  end

end
