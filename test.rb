
#require 'pry'
require './gv.rb'

class MyGraph
  include Gv::Graph

  mod_type    :service, color: 'blue', penwidth: 3, shape: 'box'
  mod_type    :rails, shape: 'folder'
  mod_type    :handset, shape: 'octagon'

  flow_type   :control_flow, arrowhead: 'dot', penwidth: 0.5
  flow_type   :data_flow, penwidth: 2.5, color: 'blue', fontcolor: 'blue'
  flow_type   :signal_flow, penwidth: 1.5, color: 'green', fontcolor: 'green'

  service :mario,   "Mario",  rank: 2
  service :luigi,   "Luigi",  rank: 1
  service :bowser,  "Bowser", rank: 3

  handset :android, "Android"

  rails   :peach,   "Princess Peach"

  action :fly do |a|
    a.control_flow  :start_to_fly, "Fly", [:bowser, :mario, :peach]
    a.data_flow     :fly_power, "Pixie Dust", [:peach, :mario]

    a.control_flow  :permission_to_fly, "Fly OK", [:peach, :luigi]
    a.signal_flow    :fly_magic, "Fly Magic", [:luigi, :peach]
  end
end

g = MyGraph.new
puts g.to_s
#binding.pry

