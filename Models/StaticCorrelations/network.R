
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
#  - components
#  - clustering coefs
#  - graph size (-> density)


#'
#' basic stats
#'
networkSize <- function(g){
  res=list()
  res$vcount=vcount(g);res$ecount=ecount(g)
  if(vcount(g)>0){res$density = ecount(g)/(vcount(g)*(vcount(g)-1)/2)}
  else{res$density=0}
  return(res)
}

#'
#' mean betweenness
networkBetweenness <- function(g){
  b=betweenness(g,weights=E(g)$length,normalized=TRUE)
  res=list()
  b[is.nan(b)|is.na(b)]=0
  if(length(b)>0){
    res$meanBetweenness = mean(b)
    if(length(which(is.finite(log(b))))>0){
      res$alphaBetweenness = lm(data = data.frame(x=log(1:length(which(is.finite(log(b))))),y=sort(log(b)[is.finite(log(b))],decreasing = TRUE)),formula = y~x)$coefficients[2]
    }else{res$alphaBetweenness = 0}
  }
  else{res$meanBetweenness = 0;res$alphaBetweenness=0}
  # hierarchy
  return(res)
}


# check distribution
# -> better with weights
#plot(log(1:length(V(g))),sort(log(betweenness(g,weights=E(g)$length)),decreasing = TRUE))

networkCloseness <- function(g){
  b = closeness(g,weights=E(g)$length,normalized=TRUE)
  res=list()
  b[is.nan(b)|is.na(b)]=0
  if(length(b)>0){
    res$meanCloseness = mean(b)
    if(length(which(is.finite(log(b))))>0){
      res$alphaCloseness = lm(data = data.frame(x=log(1:length(which(is.finite(log(b))))),y=sort(log(b)[is.finite(log(b))],decreasing = TRUE)),formula = y~x)$coefficients[2]
    }else{res$alphaBetweenness = 0}
  }
  else{res$meanCloseness = 0;res$alphaCloseness=0}
  return(res)
}

#plot(log(1:length(V(g))),sort(log(closeness(g,weights=E(g)$length)),decreasing = TRUE))

#'
#' mean link length
meanLength<-function(g){
  return(mean(E(g)$length))
}

#'
#' mean degree
#'
meanDegree<-function(g){
  return(mean(degree(g)))
}

#'
#' mean clust coef
#'
meanClustCoef<-function(g){
  return(mean(transitivity(g,type="weighted",weights=E(g)$length,isolates="zero")))
}


#'
#' components
#'
componentsNumber<-function(g){
  return(length(components(g)$csize))
}

#'
#' Network performance
pathMeasures <-function(g){
  if(vcount(g)==0){return(list(networkPerf=NA,meanPathLength=NA,diameter=NA))}
  d = distances(g,weights=E(g)$length)
  diag(d)<-1
  n=length(V(g))
  xi=matrix(rep(V(g)$x,n),nrow = n,byrow = TRUE);xj=matrix(rep(V(g)$x,n),nrow = n,byrow = FALSE)
  yi=matrix(rep(V(g)$y,n),nrow = n,byrow = TRUE);yj=matrix(rep(V(g)$y,n),nrow = n,byrow = FALSE)
  deucl = sqrt((xi-xj)^2+(yi-yj)^2)
  r = deucl / d
  res=list()
  res$networkPerf = sum(r)/n*(n-1)
  res$meanPathLength = mean(d[d!=Inf])
  res$diameter = max(d[d!=Inf])
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

