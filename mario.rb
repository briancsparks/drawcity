
require "./mod.rb"

class Mario < Graph
  mods :pftwService, :pftwApp, :agent, :mi6, :jobFlow, :browser, :printer, :appServer

  mi6          "MI6"
  pftwService  "printFromTheWeb Service"
  jobFlow      "Job Flow"
  agent        "Agent"
  browser      "Browser"                 ,shape: :octagon
  printer      "Printer"                 ,shape: :octagon
  pftwApp      "printFromTheWeb App"     ,shape: :folder
  appServer    "Application"             ,shape: :folder

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
  imageUrl    "URL", [:pftwApp, :pftwService, :jobFlow]
  imagePng    "PNG", [:appServer, :jobFlow]

end

m = Mario.new
m.to_s
