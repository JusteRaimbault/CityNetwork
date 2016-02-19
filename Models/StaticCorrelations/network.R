
###
#  Network functions
###

library(igraph)
library(RPostgreSQL)
library(rgeos)
library(rgdal)

pgsqlcon = dbConnect(dbDriver("PostgreSQL"), dbname="osm",user="Juste",host="localhost" )

##dbListTables(pgsqlcon)
#latmin=22.3;lonmin=60.6;latmax=22.32;lonmax=60.7 # test on finland

#  returns an igraph object corresponding to roads inside given extent
loadRoadData <- function(latmin,latmax,lonmin,lonmax,width){
  query = dbSendQuery(pgsqlcon,
    paste0("SELECT ST_AsText(linestring) AS geom FROM ways",
    " WHERE ST_DWithin(linestring,  ST_MakeEnvelope(",
    latmin,",",lonmin,",",latmax,",",latmin,",4326), 0.05);")
  )
  
  data = fetch(query,n=-1)
  
  geoms = data$geom
  
  # transform into Spobjects ?
  #  -> readWKT from rgeos package
  roads=list()
  for(i in 1:length(geoms)){
    r=readWKT(geoms[i])@lines[[1]];r@ID=as.character(i)
    roads[[i]]=r
  }
  
  #sapply(roads,function(l){length(l@lines[[1]]@Lines)})
  roadsdf = SpatialLines(LinesList = roads)
  
  # get coordinates
  plot(roadsdf,col=1:length(geoms))
  plot(gSimplify(roadsdf,tol=0.001));length(gSimplify(roadsdf,tol=0.001))
  #spplot(roads[[1]]);for(i in 2:10){spplot(roads[[i]],col=i,add=T)}
  m=gLineMerge(roadsdf)
  plot(m,col=1:length(m@lines[[1]]@Lines))
  roadsdf@lines
  
  # to igraph object
  
  
}


linesToGraph<-function(lines)


##  network indicators






