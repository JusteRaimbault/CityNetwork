
# get a sample graph


setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))
source('nwSimplFunctions.R')

densraster <- raster(paste0(Sys.getenv("CN_HOME"),"/Data/PopulationDensity/raw/density_wgs84.tif"))

global.dbport=5433;global.dbuser="juste";global.dbhost="";global.nwdb='nw_simpl_4'

latmin=48.3;latmax=48.5;lonmin=2.5;lonmax=2.9 # full centre -- pb : bord effects
#latmin=42.5;latmax=45.5;lonmin=2.0;lonmax=3.9

g = graphFromEdges(graphEdgesFromBase(lonmin,latmin,lonmax,latmax,dbname=global.nwdb),densraster,from_query = FALSE)

save(g,file='sample/roads_bleau.RData')
#save(g,file='sample/roads_rnd.RData')


######
#load('sample/roads_rnd.RData')
#load('sample/roads_bleau.RData')

