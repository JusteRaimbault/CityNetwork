
###
#  compute morpho and network indicators
#

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))
source('nwSimplFunctions.R');source('network.R');source('morpho.R')

#densraster <- getRaster(paste0(Sys.getenv("CN_HOME"),"/Data/PopulationDensity/raw/density_wgs84.tif"),newresolution=0,reproject=F)
#densraster <- getRaster(paste0(Sys.getenv("CN_HOME"),"/Data/China/PopulationGrid_China2010/PopulationGrid_China2010.tif"),newresolution=100,reproject=T)
densraster <- getRaster(paste0(Sys.getenv("CN_HOME"),"/Data/China/PopulationGrid_China2010/pop2010_100m_wgs84.tif"),newresolution=0,reproject=F)


#global.dbport=5433;global.dbuser="Juste";global.dbhost="localhost";global.nwdb='nwtest_simpl_4'
global.dbport=5433;global.dbuser="juste";global.dbhost="";global.nwdb='china_nw_simpl_4'

latmin=extent(densraster)@ymin;latmax=extent(densraster)@ymax;
lonmin=extent(densraster)@xmin;lonmax=extent(densraster)@xmax
#latmin=46.3;latmax=49.0;lonmin=0.0;lonmax=3.2 # full centre -- pb : bord effects

#areaname = 'europe'
areaname = 'china'
#areaname = 'centre'
areasize = 100
factor=0.1
offset = 50
# estimated comp time : 1461240*0.02539683/20/60 ~ 30hours
# (upper bound, without empty areas)

#purpose = paste0(areaname,'coupled_areasize',areasize,'_offset',offset,'_factor',factor,'_')
purpose = paste0('test_',areaname,'_coupled_areasize',areasize,'_offset',offset,'_factor',factor,'_')

# coords using lon-lat
coords <- getCoordsOffset(densraster,lonmin,latmin,lonmax,latmax,areasize,offset)

morphoFunctions<-c(summaryPopulation,rankSizeSlope,moranIndex,averageDistance,entropy)
networkFunctions<-c(networkSummary,networkBetweenness,pathMeasures,louvainModularity)

# create // cluster
library(doParallel)
#cl <- makeCluster(20,outfile='log')
cl <- makeCluster(4,outfile='logtest')
registerDoParallel(cl)

startTime = proc.time()[3]


#values = data.frame()
#for(i in 1:nrow(coords)){show(i)

#res <- foreach(i=1:nrow(coords)) %dopar% {
res <- foreach(i=1:2000) %dopar% {
  #show(i)
  tryCatch({
  source('morpho.R');source('nwSimplFunctions.R');source('network.R')
  morphoFunctions<-c(summaryPopulation,rankSizeSlope,moranIndex,averageDistance,entropy)
  networkFunctions<-c(networkSummary,networkBetweenness,pathMeasures,louvainModularity)
  
  
  lonmin=coords[i,1];lonmax=coords[i,3];latmin=coords[i,4];latmax=coords[i,2]
  y=rowFromY(densraster,latmin);x=colFromX(densraster,lonmin);
  e<-getValuesBlock(densraster,row=y,nrows=areasize,col=x,ncols=areasize)
  g = graphFromEdges(graphEdgesFromBase(lonmin,latmin,lonmax,latmax,dbname=global.nwdb),densraster,from_query = FALSE)
  if(vcount(g)>0){V(g)$population <- getPopulation(g,densraster)}
  xcor = (lonmin + lonmax / 2);ycor = (latmin + latmax) / 2
  nores=c(xcor=xcor,ycor=ycor)
  for(f in morphoFunctions){nores=append(nores,unlist(f()))}
  for(f in networkFunctions){nores=append(nores,unlist(f()))}
  
  if(sum(is.na(e))/length(e)<0.5){
    res=tryCatch({
      m=simplifyBlock(e,factor,areasize)
      res = c(xcor=xcor,ycor=ycor)
      for(f in morphoFunctions){res=append(res,unlist(f(m)))}
      for(f in networkFunctions){res=append(res,unlist(f(g)))}
      return(res)
	   }
    ,error=function(e){return(res=nores)})
  }else{res=nores}
  return(res)
  },error=function(e){return(res=NA)})
  #values=rbind(values,res)
  #colnames(values)<-names(res)
}

stopCluster(cl)


save(res,file=paste0('res/',purpose,'temp.RData'))
#load(paste0('res/coupled_',purpose,'temp.RData'))

# get results into data frame
#vals_mat = matrix(0,length(res),length(res[[1]]))

#for(a in 1:length(res)){show(res[[a]]);vals_mat[a,]=res[[a]]}

#eres=lapply(res,function(r){if(length(r)==21){c(r,NA)}else{r}})
#v=data.frame(matrix(data=unlist(eres),nrow = length(eres),byrow=TRUE))
#v = data.frame(vals_mat);


#colnames(v)=c("lonmin","latmin","moran","distance","entropy","slope","rsquaredslope",
#              "pop","max","meanBetweenness","alphaBetweenness",
#              "meanCloseness","alphaCloseness",
#              "meanLinkLength","networkPerf",
#              "meanPathLength","diameter","components","clustCoef",
#              "vcount","ecount","networkDensity"
#              )


show(paste0("Ellapsed Time : ",proc.time()[3]-startTime))

# 
# # store in data file
#write.table(
#   v,
#   file=paste0('res/',purpose,format(Sys.time(), "%a-%b-%d-%H:%M:%S-%Y"),'.csv'),
#   sep = ";",
#   col.names=colnames(v)
#)
# 




