
require 'pry'
require './gv.rb'

class MyGraph
  include Gv::Graph

  mod_type :service, color: 'blue', penwidth: 3, shape: 'box'

  service :mi6, "MI6", rank: 2
  service :luigi, "Luigi", rank: 1
end

g = MyGraph.new
puts g.to_s
binding.pry

