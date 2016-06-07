
## road network simplification

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))

## Do not use osm directly, not efficient

#latmin=5.5;latmax=6.5;lonmin=49.0;lonmax=51

source('nwSimplFunctions.R')

#wgs84='+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'


# get raster from density data -> will be directly consistent.
densraster <- raster(paste0(Sys.getenv("CN_HOME"),"/Data/PopulationDensity/raw/density_wgs84.tif"))
latmin=extent(densraster)@ymin;latmax=extent(densraster)@ymax;
lonmin=extent(densraster)@xmin;lonmax=extent(densraster)@xmax

tags=c("motorway","trunk","primary","secondary","tertiary","unclassified")
roads<-linesWithinExtent(lonmin,latmin,lonmax,latmax,tags)
#splines = SpatialLines(LinesList = roads$roads)
#densraster<-raster(extent(splines),nrow=500,ncol=500)


# edgelist of connexions between raster cells
edgelist <- graphEdgesFromLines(roads = roads,baseraster = densraster)

edgesmat=matrix(data=as.character(unlist(edgelist$edgelist)),ncol=2,byrow=TRUE);
g = graph.data.frame(data.frame(edgesmat,speed=edgelist$speed,type=edgelist$type),directed=FALSE)
coords = xyFromCell(densraster,as.numeric(V(g)$name))
V(g)$x=coords[,1];V(g)$y=coords[,2]

sg = simplifyGraph(g)

exportGraph(sg,dbname="nw",dbuser="juste")

