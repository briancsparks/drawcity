
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

      def mod_type(type_sym, type_options = {})
        @mod_types ||= {}

        cl = Class.new do
          include Gv::Item
          @type_options = type_options

          class << self
            def type_options
              @type_options
            end
          end
        end

        @mod_types[type_sym] = cl

        metaclass.instance_eval do
          define_method(type_sym) do |sym, name, options = {}|
            @mods ||= {}
            @mods[sym] = @mod_types[type_sym].new sym, name, options
          end
        end

      end

      def to_s
        "" + @mods.map do |k,v|
          v.render
        end.join("\n") 
      end

    end

  end

end
