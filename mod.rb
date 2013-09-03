
module GraphMod
  def metaclass; class << self; self; end; end

  def mods( *arr )
    return @mods if arr.empty?

    attr_accessor(*arr)

    arr.each do |a|
      metaclass.instance_eval do 
        define_method(a) do |label, options={}|
          @mods ||= {}
          @mods[a] = options
          @mods[a][:label] = label

        end
      end
    end

    # Define class-level methods
    class_eval do
      define_method( :initialize ) do
        self.class.mods.each do |k,v|
          instance_variable_set("@#{k}", v)
        end
      end

      # The magic function to create the output
      define_method( :to_s ) do

        puts "digraph {"

        # The modules
        self.class.mods.each do |k,v|
          x = v.map do |vk, vv|
            "#{vk}=\"#{vv}\""
          end.join(' ')

          puts "  #{k} [#{x}];"
        end

        # Data flow
        self.class.flows.each do |k,v|
          puts ""
          puts "  // #{v['name']}"
          puts "  " + v['mods'].join(' -> ') + " [color=blue penwidth=2.5];"
        end

        # Control flow
        self.class.cflows.each do |k,v|
          puts ""
          puts "  // control -- #{v['name']}"
          puts "  " + v['mods'].join(' -> ') + " [arrowhead=dot penwidth=0.5];"
        end

        puts "}"
      end
    end

  end

  #
  # Data flows
  #
  def flows( *arr )
    return @flows if arr.empty?

    attr_accessor(*arr)

    arr.each do |a|
      metaclass.instance_eval do

        # A flow type
        define_method( a ) do |name, mods, options={}|
          @flows ||= {}
          @flows[a] = options
          @flows[a]['name'] = name
          @flows[a]['mods'] = mods
        end

      end
    end
  end

  #
  # Control Flows
  #
  def cflows( *arr )
    return @cflows if arr.empty?

    #attr_accessor( *arr )

    arr.each do |a|
      name = "c#{a}"
      attr_accessor( name )

      metaclass.instance_eval do

        # A flow type
        define_method( name ) do |flow_name, mods, options={}|
          @cflows ||= {}
          @cflows[name] = options
          @cflows[name]['name'] = flow_name
          @cflows[name]['mods'] = mods
        end

      end
    end
  end

end

class Graph
  extend GraphMod
  #mkflows :a, "A", foo: :bar
end
