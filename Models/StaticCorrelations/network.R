
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



getPopulation<-function(g,densraster){
  if(vcount(g)==0){return(c())}
  verticessp=SpatialPoints(data.frame(x=V(g)$x,y=V(g)$y),proj4string = crs(densraster))
  ext = extent(verticessp)
  vertices = ppp(V(g)$x,V(g)$y,window=owin(c(ext@xmin,ext@xmax),c(ext@ymin,ext@ymax)))
  diric = dirichlet(vertices)
  for(i in 1:length(diric$tiles)){diric$tiles[[i]]$id = V(g)$name[i]}
  diricsp = SpatialPolygons(lapply(diric$tiles,function(tile){
    Polygons(list(Polygon(
      matrix(data=c(tile$bdry[[1]]$x,tile$bdry[[1]]$x[1],tile$bdry[[1]]$y,tile$bdry[[1]]$y[1]),nrow=length(tile$bdry[[1]]$x)+1,byrow=F)        
    )),ID = tile$id)})
  ,proj4string = crs(densraster)
  )
  cropped = crop(densraster,ext)
  extr = extract(cropped,diricsp,na.rm=T,fun=sum,df=T)#weights=T,normalizeWeights=F)
  # ex : 931.49767 instead of 907.5153 -> ok use direct computation
  return(extr[,2])
}


#'
#' basic stats
#'
networkSize <- function(g){
  res=list()
  if(vcount(g)>0){
    res$density = ecount(g)/(vcount(g)*(vcount(g)-1)/2)
    res$vcount=vcount(g);res$ecount=ecount(g)
  }
  else{
    res$density=0
    res$vcount=0;res$ecount=0
  }
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
  if(vcount(g)==0){return(0)}
  return(mean(E(g)$length))
}

#'
#' mean degree
#'
meanDegree<-function(g){
  if(vcount(g)==0){return(0)}
  return(mean(degree(g)))
}

#'
#' mean clust coef
#'
meanClustCoef<-function(g){
  if(vcount(g)==0){return(0)}
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
  # TODO nw perf is not normalized by distance -- cannot be compared
  diag(d)<-Inf
  res$meanPathLength = mean(d[d!=Inf])
  res$diameter = max(d[d!=Inf])
  # renormalize networkPerf for comparability (TODO add d^{eucl}_{max})
  res$networkPerf = res$networkPerf * res$meanPathLength
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

