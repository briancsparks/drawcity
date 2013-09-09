
def gv_ify(options)
  '' + options.map do |k,v|
    "#{k}=\"#{v}\""
  end.join(' ')
end

module Gv

  module Item
    def self.included(child)
      child.extend ClassMethods
    end

    def initialize(sym, name, list, options={})
      @sym, @name, @list, @options = sym, name, list, options

      if @options[:rank]
        @rank = @options[:rank]
        @options.delete(:rank)
      end
      
    end

    def render
      if @list.empty?
        "#{@sym} [#{label_item}#{options}];"
      else
        "#{flow} [#{label_item}#{options}];"
      end
    end

    def flow
      @list.join(' -> ')
    end

    def label_item
      return "label=\"#{@name}\" " if !@name.empty?
      ""
    end

    def options
      gv_ify(type_options.merge(@options))
    end

    def type_options
      self.class.type_options
    end

    def hello
      "world"
    end

    module ClassMethods
      def hello_from_class
        "World"
      end
    end

  end

end
