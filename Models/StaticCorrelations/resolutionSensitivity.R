
setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))

source('functions.R')
source('mapFunctions.R')

countrycode="FR"

areasize=200;offset=100;factor=0.5
res1 = loadIndicatorData(paste0("res/europecoupled_areasize",areasize,"_offset",offset,"_factor",factor,"_temp.RData"))

areasize=100;offset=50;factor=0.5
res2 = loadIndicatorData("res/res/europe_areasize100_offset50_factor0.5_20160824.csv")


######
unique(sort(res1$latmin))


