
# Map accessibility changes in PRD

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/CaseStudies/PRD'))

library(rgdal)
library(raster)

source(paste0(Sys.getenv('CN_HOME'),'/Models/TransportationNetwork/NetworkAnalysis/network.R'))

trgraph=addTransportationLayer(link_layer = 'data/networkBaidu.shp',speed=6e-04,snap=10)
#plot(trgraph,vertex.size=rep(0,vcount(trgraph)),vertex.label=rep(NA,vcount(trgraph)))

# read the population raster
pop = raster(x = 'data/pop2010_wgs84_georef.asc')
popdata =  data.frame(cbind(xyFromCell(pop,1:ncell(pop)),pop=getValuesBlock(pop,nrows=nrow(pop),ncols=ncol(pop))))

poppoints = SpatialPointsDataFrame(popdata[popdata$pop>0,c("x","y")],popdata[popdata$pop>0,])

trbase = addAdministrativeLayer(trgraph,poppoints,connect_speed = 0.1,attributes=list("pop"="pop"))

trbridge=addTransportationLayer(link_layer = 'data/networkPlannedBaidu.shp',g = trbase,speed=6e-04,snap=10)

#save(trgraph,trbase,file='processed/graphs.RData')
load('processed/graphs.RData')

distmat = distances(graph = trbase,v = which(V(trbase)$station==0),to = which(V(trbase)$station==1),weights = E(trbase)$speed*E(trbase)$length)




