
setwd(paste0(Sys.getenv('CN_HOME'),'/Models/DataProcessing/Train'))

library(rgdal)

source(paste0(Sys.getenv('CN_HOME'),'/Models/TransportationNetwork/NetworkSimplification/nwSimplFunctions.R'))

# load raw data
troncons=readOGR(paste0(Sys.getenv('CN_HOME'),'/Data/Train/DONNEES'),'Donnees_completes_RESEAU_FERROVIAIRE')


