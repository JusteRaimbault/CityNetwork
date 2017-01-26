
#####
# Sud-afriquie case study
#  data preparation


# population

popdatadir = paste0(Sys.getenv('CN_HOME'),'/Data/SudAfrica/pop')
years = c(1911,1921,1936,1951,1960,1970,1980,1991)






# network

library(rgdal)
library(rgeos)
library(igraph)
nwdir = paste0(Sys.getenv('CN_HOME'),'/Data/SudAfrica/BDD_SA_reseau')

stations = readOGR(nwdir,'STATIONS')
troncons = readOGR(nwdir,'TRONCONS')
troncons@data$CLOSED[troncons@data$CLOSED==0]=3000

gDisjoint(SpatialPoints(matrix(stations@coords[1,],nrow=1),proj4string = stations@proj4string),troncons)

constructGraph<-function(year){
   indexes = which(troncons@data$OPENED<year&troncons@data$CLOSED>year)
   for(i in indexes){
     coords = troncons@lines[[i]]@Lines[[1]]@coords
     disto = colSums(apply(stations@coords,1,function(r){abs(r-coords[1,])}));rowo=which(dists==min(dists))
     distd = colSums(apply(stations@coords,1,function(r){abs(r-coords[2,])}));rowd=which(dists==min(dists))
     
   }
}
