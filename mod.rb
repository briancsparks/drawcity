
def grout(str)
  puts str
end

def attrs(x_, options = {})
  x = x_
  x = x.merge(options[:extra]) if !options[:extra].nil?

  str = x.map do |k, v|
    if !options[:skip].nil?
      "#{k}=\"#{v}\"" unless options[:skip].include? k
    else
      "#{k}=\"#{v}\""
    end
  end.join(' ')

  "[ #{str} ]"
end

module GvItemMod
  def geom(options)
    @geom ||= {}

    options.each do |k, v|
      #attr_accessor(k)
      @geom[k] = v
    end

    # Define class-level methods
    #class_eval do
      define_method( :initialize ) do | options_ |
        @geom ||= {}

        options_.merge(options).each do |k, v|
          if (k == :rank)
            @rank = v
          else
            @geom[k] = v
          end
        end
      end

      define_method( :rank ) do
        return @rank || 99
      end

      define_method( :to_s ) do
        "#{attrs(@geom)}"
      end
    #end

  end

end

class GvItem
  extend GvItemMod
end

module GraphMod
  def metaclass; class << self; self; end; end

  def mods2( *arr )
    return @mods2 || {} if arr.empty?

    arr.each do |name|
      metaclass.instance_eval do
        define_method(name) do |item|
          @mods2 ||= {}
          @mods2[name] = {}
          @mods2[name][:item] = item
        end
      end
    end
  end

  def mods( *arr )
    return @mods if arr.empty?

    attr_accessor(*arr)

    arr.each do |a|
      metaclass.instance_eval do 
        define_method(a) do |label, options={}|
          @mods ||= {}
          @mods[a] = options
          @mods[a][:label] = label

          if options[:type] == :rails
            @mods[a][:shape] = :folder
          elsif options[:type] == :notSw
            @mods[a][:shape] = :octagon
          else #options[:type] == :networking
            @mods[a][:shape] = :box
            @mods[a][:penwidth] = 3
            @mods[a][:color] = :blue
          end

          #@mods[a].delete :rank
          @mods[a].delete :type

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

        grout "digraph {"
        grout "  rankdir=TB;"
        #grout "  splines=true;"
        grout "  nodesep=1.5;"
        grout "  ranksep=1.0;"

        # The modules
        (1..10).each do |r|

          node_group = []

          self.class.mods.each do |k,v|
            if v[:rank] == r
              node_group << "    #{k} #{attrs(v, skip: [:rank])};"
            end
          end

          self.class.mods2.each do |k,v|
            if v[:item].rank == r
              node_group << "    #{k} #{v[:item]};"
            #  node_group << "    #{k} #{attrs(v, skip: [:rank])};"
            end
            #node_group << m.to_s
          end

          if node_group.length > 0
            grout "  {\n    rank=same; "
            grout node_group.join("\n")
            grout "  }"
          end
        end

        # Data flow
        self.class.flows.each do |k,v|
          if v[:importance] != :secondary
            grout ""
            grout "  // #{v[:name]}"
            grout "  #{v[:mods].join(' -> ')} #{attrs(v, extra: {color: 'blue', penwidth: 2.5}, skip: [:mods])};"
          end
        end

        # Data flow -- secondary
        self.class.flows.each do |k,v|
          if v[:importance] == :secondary
            grout ""
            grout "  // #{v[:name]}"
            grout "  #{v[:mods].join(' -> ')} #{attrs(v, extra: {color: 'blue', penwidth: 1.0}, skip: [:mods])};"
          end
        end

        # Control flow
        self.class.cflows.each do |k,v|
          grout ""
          grout "  // control -- #{v[:name]}"
          grout "  #{v[:mods].join(' -> ')} #{attrs(v, extra: {arrowhead: 'dot', penwidth: 0.5}, skip: [:mods])};"
        end

        grout "}"
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
          @flows[a][:label] = name
          @flows[a][:mods] = mods
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
          @cflows[name][:label] = flow_name
          @cflows[name][:mods] = mods
        end

      end
    end
  end

end

class Graph
  extend GraphMod
  #mkflows :a, "A", foo: :bar
end
