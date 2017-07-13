
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
networkSummary <- function(g=NULL){
  if(is.null(g)){return(list(vcount=NA,ecount=NA,gamma=NA,meanDegree=NA,mu=NA,alpha=NA,meanLinkLength=NA,meanNodePop=NA,meanClustCoef=NA,components=NA))}
  if(vcount(g)==0){return(list(vcount=0,ecount=0,gamma=0,meanDegree=0,mu=1,alpha=0,meanLinkLength=0,meanNodePop=0,meanClustCoef=0,components=0))}
  return(
    list(
      vcount=vcount(g),
      ecount=ecount(g),
      gamma = 2*ecount(g)/(vcount(g)*(vcount(g)-1)),
      meanDegree = mean(degree(g)),
      mu = ecount(g) - vcount(g) + 1,
      alpha = (ecount(g) - vcount(g) + 1)/(2*vcount(g)-5),
      meanLinkLength=mean(E(g)$length),
      meanNodePop=mean(V(g)$population),
      meanClustCoef=mean(transitivity(g,type="weighted",weights=E(g)$length,isolates="zero")),
      components = length(components(g)$csize)
    )
  )
}

#'
#' mean betweenness
#'  -- do not compute pop weighted betweenness, too costly to go through all paths --
networkBetweenness <- function(g=NULL){
  if(is.null(g)){return(list(meanBetweenness=NA,alphaBetweenness=NA))}
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



hierarchy<-function(b){
  res=list()
  b[is.nan(b)|is.na(b)]=0
  if(length(b)>0){
    res$mean= mean(b)
    if(length(which(is.finite(log(b))))>0){
      res$alpha = lm(data = data.frame(x=log(1:length(which(is.finite(log(b))))),y=sort(log(b)[is.finite(log(b))],decreasing = TRUE)),formula = y~x)$coefficients[2]
    }else{res$alpha = 0}
  }
  else{res$mean = 0;res$alpha=0}
  return(res)
}


#'
#' Path related measures
#'   - diameter
#'   - euclidian perf (detours)
#'   - distance closeness mean = average path length
#'   - distance closeness alpha
#'   - average travel time (perf with speed) = time closeness mean
#'   - avreage travel time alpha
#'   - weighted travel time closeness = accessibility mean
#'   - accessibility alpha
pathMeasures <-function(g=NULL){
  if(is.null(g)){return(list(diameter=NA,euclPerf=NA,meanCloseness=NA,alphaCloseness=NA,meanTravelTime=NA,alphaTravelTime=NA,meanAccessibility=NA,alphaAccessibility=NA))}
  if(vcount(g)==0){return(list(diameter=NA,euclPerf=NA,meanCloseness=NA,alphaCloseness=NA,meanTravelTime=NA,alphaTravelTime=NA,meanAccessibility=NA,alphaAccessibility=NA))}
  res=list()
  
  # adjust missing speeds
  E(g)$speed[E(g)$speed==0]=50
  
  # compute distances and times
  d = distances(g,weights=E(g)$length)
  times = distances(g,weights=E(g)$length/E(g)$speed)
  
  diag(d)<-Inf
  # compute eucl matrix
  n=length(V(g))
  xi=matrix(rep(V(g)$x,n),nrow = n,byrow = TRUE);xj=matrix(rep(V(g)$x,n),nrow = n,byrow = FALSE)
  yi=matrix(rep(V(g)$y,n),nrow = n,byrow = TRUE);yj=matrix(rep(V(g)$y,n),nrow = n,byrow = FALSE)
  deucl = sqrt((xi-xj)^2+(yi-yj)^2)
  r = deucl / d
  res$euclPerf = sum(r)/n*(n-1)
  res$diameter = max(d[d!=Inf])
  
  # closeness
  closeness = hierarchy(apply(d,1,function(r){mean(1/r)}))
  res$meanCloseness = closeness$mean;res$alphaCloseness = closeness$alpha
  
  # travel time
  times[times==Inf]=0
  traveltime = hierarchy(apply(times,1,function(r){mean(r)}))
  res$meanTravelTime = traveltime$mean;res$alphaTravelTime = traveltime$alpha
  
  # accessibility
  accessibilities = (times%*%matrix(data=V(g)$population/sum(V(g)$population),nrow=nrow(times)))[,1]
  res$alphaAccessibility=hierarchy(accessibilities)$alpha
  res$meanAccessibility = sum(accessibilities*V(g)$population/sum(V(g)$population))
  
  return(res)
}



louvainModularity<-function(g=NULL){
  if(is.null(g)){return(list(modularity=NA))}
  com=cluster_louvain(g)
  return(list(
    modularity = max(com$modularity)
  ))
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

