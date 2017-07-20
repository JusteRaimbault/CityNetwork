
setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))

library(RMongo)
mongo<-mongoDbConnect('china','127.0.0.1',29019)

source('nwSimplFunctions.R')
source('network.R');source('morpho.R')
densraster <- getRaster(paste0(Sys.getenv("CN_HOME"),"/Data/China/PopulationGrid_China2010/pop2010_100m_wgs84.tif"),newresolution=0,reproject=F)

lonmin=125;lonmax=126;latmin=49;latmax=50
g = graphFromEdges(graphEdgesFromBase(lonmin,latmin,lonmax,latmax,dbparams=defaultDBParams(dbname='china')),densraster,from_query = FALSE)

show(g)
