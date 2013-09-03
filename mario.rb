
require "./mod.rb"

class Mario < Graph
  mods :pftwService, :pftwApp, :agent, :mi6, :jobFlow, :browser, :printer, :appServer

  pftwApp      "printFromTheWeb App"      , rank: 1, type: :rails
  jobFlow      "Job Flow"                 , rank: 1
  appServer    "Application"              , rank: 1, type: :rails

  mi6          "MI6"                      , rank: 2
  pftwService  "printFromTheWeb Service"  , rank: 2

  agent        "Agent"                    , rank: 3

  browser      "Browser"                  , rank: 4, type: :notSw
  printer      "Printer"                  , rank: 4, type: :notSw

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
  imagePng    "PNG", [:appServer, :jobFlow], importance: :secondary

end

m = Mario.new
m.to_s
