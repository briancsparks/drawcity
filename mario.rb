
require 'pry'
require "./mod.rb"

class RailsApp < GvItem
  geom color: 'blue', penwidth: 2.5, shape: 'folder'
end

class NetService < GvItem
  geom color: 'blue', penwidth: 3, shape: 'box'
end

class NotSw < GvItem
  geom shape: 'octagon'
end

class Mario < Graph

  mods :brian
  mods2 :browser, :printer, :agent, :pftwService, :appServer, :pftwApp, :jobFlow, :mi6

  pftwApp       RailsApp.new(label: "printFromTheWeb App", rank: 1)
  jobFlow       NetService.new(label: "Job Flow", rank: 1)
  appServer     RailsApp.new(label: "Application", rank: 1)

  pftwService   NetService.new(label: "printFromTheWeb Service", rank: 2)
  mi6           NetService.new(label: "MI6", rank: 2)

  agent         NetService.new(label: "Agent", rank: 3)

  browser       NotSw.new(label: "Browser", rank: 4)
  printer       NotSw.new(label: "Priner", rank: 4)

  # Control flows -- invoking print, get the PCL
  cflows :print, :getPcl
  cprint "Print", [:browser, :pftwService, :mi6, :agent]
  cgetPcl "Get PCL", [:agent, :mi6, :jobFlow]

  # Control flows -- get the image's URL, get the image
  cflows :getImageUrl, :getImage
  cgetImageUrl  "Get Image Url", [:jobFlow, :pftwService, :pftwApp]
  cgetImage     "Get Image", [:jobFlow, :appServer]

  # Data flows -- the PCL, the image URL
  flows :pcl, :imageUrl, :imagePng
  pcl         "PCL", [:jobFlow, :mi6, :agent, :printer]
  imageUrl    "URL", [:pftwApp, :pftwService, :jobFlow], importance: :secondary
  imagePng    "PNG", [:appServer, :jobFlow]

end

m = Mario.new
m.to_s

