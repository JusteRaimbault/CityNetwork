
###
#  Network functions
###

library(igraph)
library(RPostgreSQL)
library(rgeos)
library(rgdal)



###########
##  network indicators

#  - distribution of betweeness
#  - distribution of degrees (CHECK road_nw analysis papers)
#  - mean path length
#  - network performance
#  - diameter ?

#'
#' mean betweenness
meanBetweenness <- function(g){
  b=betweenness(g)
  if(length(b)>0){return(mean(b))}else{return(0)}
}

#'
#' mean link length
meanLength<-function(g){
  return(mean(E(g)$length))
}

#'
#' Network performance
pathMeasures <-function(g){
  d = distances(g,weights=E(g)$length)
  diag(d)<-1
  n=length(V(g))
  xi=matrix(rep(V(g)$x,n),nrow = n,byrow = TRUE);xj=matrix(rep(V(g)$x,n),nrow = n,byrow = FALSE)
  yi=matrix(rep(V(g)$y,n),nrow = n,byrow = TRUE);yj=matrix(rep(V(g)$y,n),nrow = n,byrow = FALSE)
  deucl = sqrt((xi-xj)^2+(yi-yj)^2)
  r = deucl / d
  res=list()
  res$networkPerf = sum(r)/n*(n-1)
  res$meanPathLength = mean(d)
  res$diameter = max(d)
  return(res)
}










#############
## deprecated


##dbListTables(pgsqlcon)
#latmin=22.3;lonmin=60.6;latmax=22.32;lonmax=60.7 # test on finland

#  returns an igraph object corresponding to roads inside given extent
loadRoadData <- function(latmin,latmax,lonmin,lonmax,width){
  dbname="osm_simpl";dbuser="juste"
  pgsqlcon = dbConnect(dbDriver("PostgreSQL"), dbname=dbname,user=dbuser,host="localhost" )
  query = dbSendQuery(pgsqlcon,
                      paste0("SELECT ST_AsText(geography) AS geom FROM links",
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

