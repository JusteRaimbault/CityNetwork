
library(osmar)
library(igraph)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/Morphology/Network/TestOSM'))

#
api <- osmsource_api()
# quite slow for large areas ; use localconnexion to osm file ?
# -> using osmosis
osmosis <- osmsource_osmosis(file = paste0(Sys.getenv('CN_HOME'),'Data//OSM/')


# OLG : (2.3815,48.8265)
# height,width of box are in meters ; coordinates as decimal geographical
area <- center_bbox(2.3815,48.8265,500,500)

data <- get_osm(area,source = api)

# request
hways <- find(data, way(tags(k == "highway")))

names(data$ways)
# -> use dataframe to get objects

data$ways$attrs




