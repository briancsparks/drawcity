
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

    def initialize(sym, name, options_={})
      @sym, @name, @options = sym, name, options_

      if options_[:rank]
        @rank = options_[:rank]
        options_.delete(:rank)
      end
      
    end

    def render
      "#{@sym} [#{label_item}#{options}];"
    end

    def label_item
      return "label=\"#{@name}\" " if !@name.empty?
      ""
    end

    def options
      gv_ify(@options) + gv_ify(self.class.type_options)
      #'' + @options.map do |k,v|
      #  "#{k}=\"#{v}\""
      #end.join(' ')
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
