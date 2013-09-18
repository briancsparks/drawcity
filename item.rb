
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
      
      if @options[:action]
        @action = @options[:action]
        @options.delete(:action)
      end
      
    end

    def action
      @action
    end

    def rank
      @rank
    end

    # Return the mods that are involved with this action, if appropriate
    #
    #   involvement_action is a regular expression in a string like 'a:b:.*'
    #   action is a member like 'a:b:c'
    #
    #   Should match action === 'a', action === 'a:b', and action === 'a:b:c'
    def involved(involvement_action)
      parts = involvement_action.split(':')   # ['a', 'b', 'c']

      matchers = Range.new(0, parts.length - 1).map do |index|
        parts.slice(0, index + 1).join(':')
      end

      is_involved = false
      matchers.each do |matcher|
        if Regexp.new('^' + matcher + '$').match(action)
          is_involved = true
          break
        end
      end

      return @list if is_involved

      []

      #if involvement_action.match action
      #  @list
      #else
      #  []
      #end
    end

    def render(roptions={})
      if @list.empty?
        if roptions[:invis]
          "%14s  [%s style=invis]; // %s" % [@sym, "#{label_item}#{options}", action]
        else
          "%14s  [%s]; // %s" % [@sym, "#{label_item}#{options}", action]
        end
      else
        if roptions[:invis]
          "%44s  [%s style=invis]; // %s" % [flow, "#{label_item}#{options}", action]
        else
          "%44s  [%s]; // %s" % [flow, "#{label_item}#{options}", action]
        end
      end
    end

    def flow
      @list.join(' -> ')
    end

    def label_item
      return " %-25s" % ["label=\"#{@name}\" "] if !@name.empty?
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
