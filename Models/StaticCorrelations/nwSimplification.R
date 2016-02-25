
## road network simplification

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))

## Do not use osm directly, not efficient

latmin=5.5;latmax=6.5;lonmin=49.0;lonmax=51

library(RPostgreSQL)
library(rgeos)
library(rgdal)
library(raster)
library(igraph)
library(dplyr)

source('nwSimplFunctions.R')

#wgs84='+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'


# get raster from density data -> will be directly consistent.
#densraster <- raster(paste0(Sys.getenv("CN_HOME"),"/Data/PopulationDensity/raw/popu01clcv5.tif"))

tags=c("motorway","trunk","primary","secondary")
roads<-linesWithinExtent(latmin,lonmin,latmax,lonmax,tags)
splines = SpatialLines(LinesList = roads$roads)
densraster<-raster(extent(splines),nrow=500,ncol=500)


# edgelist of connexions between raster cells
edgelist <- graphEdgesFromLines(roads = roads,baseraster = densraster)

edgesmat=matrix(data=as.character(unlist(edgelist$edgelist)),ncol=2,byrow=TRUE);
edgesmat[,3]=edgelist$speed
edgesmat$speed=edgelist$speed;edgesmat$type=edgelist$type
data.frame(edgesmat,edgelist$speed,edgelist$type)
g = graph.data.frame(data.frame(edgesmat,speed=edgelist$speed,type=edgelist$type),directed=FALSE)
coords = xyFromCell(densraster,as.numeric(V(g)$name))
V(g)$x=coords[,1];V(g)$y=coords[,2]


#summary(degree(g))
#V(g)[which(degree(g)==max(degree(g)))]
#centralization.betweenness(g)
#diameter(g)

#sg = simplifyGraph(g)

#exportGraph(sg)

# insertion into simplified database : insert into links (id,origin,destination,geography) values ('1',10,50,ST_GeographyFromText('LINESTRING(-122.33 47.606, 0.0 51.5)')); 


