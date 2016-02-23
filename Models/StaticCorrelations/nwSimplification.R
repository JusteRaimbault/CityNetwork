
## road network simplification

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))

## Do not use osm directly, not efficient

latmin=5.5;latmax=6.5;lonmin=49.0;lonmax=51

library(RPostgreSQL)
library(rgeos)
library(rgdal)
library(raster)
library(igraph)

source('nwSimplFunctions.R')

#wgs84='+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'


# get raster from density data -> will be directly consistent.
#densraster <- raster(paste0(Sys.getenv("CN_HOME"),"/Data/PopulationDensity/raw/popu01clcv5.tif"))

tags=c("motorway","trunk","primary","secondary")
roads<-linesWithinExtent(latmin,lonmin,latmax,lonmax,tags)
splines = SpatialLines(LinesList = roads)
densraster<-raster(extent(splines),nrow=500,ncol=500)


# edgelist of connexions between raster cells
edgelist <- graphEdgesFromLines(roads = roads,baseraster = densraster)

edgesmat=matrix(data=as.character(unlist(edgelist)),ncol=2,byrow=TRUE)
g = graph_from_edgelist(edgesmat,directed=FALSE)
coords = xyFromCell(densraster,as.numeric(V(g)$name))
V(g)$x=coords[,1];V(g)$y=coords[,2]
#plot(g,layout=coords,vertex.size=0,vertex.label=NA,edge.loop.angle=NA)

#summary(degree(g))
#V(g)[which(degree(g)==max(degree(g)))]
#centralization.betweenness(g)
#diameter(g)

sg = simplifyGraph(g)

sg = g
#sg <- 

exportGraph(sg)



