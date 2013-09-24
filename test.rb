
#require 'pry'
require './drawcity/gv.rb'

class MyGraph
  include Gv::Graph

  # --------------------------------------------------------------------
  # Types
  mod_type    :service,       color: 'blue', penwidth: 3, shape: 'box'
  mod_type    :rails,         shape: 'folder'
  mod_type    :handset,       shape: 'octagon'

  flow_type   :control_flow,  arrowhead: 'dot', penwidth: 0.5
  flow_type   :data_flow,     penwidth: 2.5, color: 'blue', fontcolor: 'blue'
  flow_type   :flyweight,     penwidth: 1.5, color: 'green', fontcolor: 'green'

  # --------------------------------------------------------------------

  service :mario,   "Mario",  rank: 2
  service :luigi,   "Luigi",  rank: 1
  service :bowser,  "Bowser", rank: 3

  handset :android, "Android"

  rails   :peach,   "Princess Peach"

  action :fly do |a|
    a.control_flow  %w(bowser mario, peach),   :start_to_fly, "Fly"
    a.data_flow     %w(peach mario),           :fly_power, "Pixie Dust"

    a.control_flow  %w(peach luigi),           :permission_to_fly, "Fly OK"
    a.flyweight     %w(luigi peach),           :fly_magic, "Fly Magic"
  end
end

g = MyGraph.new
puts g.render('fly')
#binding.pry

