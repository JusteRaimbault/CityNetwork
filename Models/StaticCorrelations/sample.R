
# get a sample graph


setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))
source('nwSimplFunctions.R')

densraster <- raster(paste0(Sys.getenv("CN_HOME"),"/Data/PopulationDensity/raw/density_wgs84.tif"))

global.dbport=5433;global.dbuser="juste";global.dbhost="";global.nwdb='nw_simpl_4'

latmin=48.3;latmax=48.5;lonmin=2.5;lonmax=2.9 # full centre -- pb : bord effects
#latmin=42.5;latmax=45.5;lonmin=2.0;lonmax=3.9
#latmin=44.5;latmax=45.5;lonmin=2.9;lonmax=3.9
latmin=48.9111;latmax=49.0008;lonmin=-0.000911037;lonmax=0.142089

g = graphFromEdges(graphEdgesFromBase(lonmin,latmin,lonmax,latmax,dbname=global.nwdb),densraster,from_query = FALSE)

#save(g,file='sample/roads_bleau.RData')
#save(g,file='sample/roads_rnd.RData')
save(g,file='sample/roads_centrefirst.RData')

######
#load('sample/roads_rnd2.RData')
#load('sample/roads_bleau.RData')

#plot(SpatialPoints(data.frame(x=V(g)$x,y=V(g)$y)))
#vertices=SpatialPoints(data.frame(x=V(g)$x,y=V(g)$y))
#delaunay = gDelaunayTriangulation(vertices)
#plot(delaunay,add=T,col='red')


