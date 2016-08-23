
###
#  compute morpho and network indicators
#

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))
source('nwSimplFunctions.R')

densraster <- raster(paste0(Sys.getenv("CN_HOME"),"/Data/PopulationDensity/raw/density_wgs84.tif"))

#global.dbport=5433;global.dbuser="Juste";global.dbhost="localhost"
global.dbport=5433;global.dbuser="juste";global.dbhost=""

latmin=extent(densraster)@ymin;latmax=extent(densraster)@ymax;
lonmin=extent(densraster)@xmin;lonmax=extent(densraster)@xmax
#latmin=46.7;latmax=47.7;lonmin=1;lonmax=2.2 

areasize = 100
factor=0.5
offset = 50
# estimated comp time : 1461240*0.02539683/20/60 ~ 30hours
# (upper bound, without empty areas)

purpose = paste0('europe_areasize',areasize,'_offset',offset,'_factor',factor,'_')

# coords using lon-lat
coords <- getCoordsOffset(densraster,lonmin,latmin,lonmax,latmax,areasize,offset)




# create // cluster
library(doParallel)
cl <- makeCluster(20,outfile='log')
registerDoParallel(cl)

startTime = proc.time()[3]

res <- foreach(i=1:nrow(coords)) %dopar% {
  show(i)
  #for(i in 1:nrow(coords)){show(i)
  source('morpho.R');source('nwSimplFunctions.R');source('network.R')
  lonmin=coords[i,1];lonmax=coords[i,3];latmin=coords[i,4];latmax=coords[i,2]
  x=rowFromY(densraster,latmin);y=colFromX(densraster,lonmin);
  e<-getValuesBlock(densraster,row=x,nrows=areasize,col=y,ncols=areasize)
  g = graphFromEdges(graphEdgesFromBase(lonmin,latmin,lonmax,latmax,dbname='nw_simpl_4'),densraster,from_query = FALSE)
  if(sum(is.na(e))/length(e)<0.5){
    res=tryCatch({
    #show("computing indicators...")
    m=simplifyBlock(e,factor,areasize)
    r_pop = raster(m/100);r_dens = raster(m/sum(m))
    pm = pathMeasures(g)
    bw = networkBetweenness(g);cl = networkCloseness(g)
    ns=networkSize(g)
    return(c(lonmin,latmin,moranIndex(r_dens = r_dens),averageDistance(r_pop = r_pop),
          entropy(r_dens = r_dens),rankSizeSlope(r_pop = r_pop),
          totalPopulation(r_pop=r_pop),maxPopulation(r_pop=r_pop),
          bw$meanBetweenness,bw$alphaBetweenness,cl$meanCloseness,cl$alphaCloseness,
          meanLength(g),pm$networkPerf,pm$meanPathLength,pm$diameter,
          componentsNumber(g),meanClustCoef(g),ns$vcount,ns$ecount,ns$density
          ))
	}
    ,error=function(e){return(res=c(lonmin,latmin,rep(NA,19)))})
  }
  else{res=c(lonmin,latmin,rep(NA,19))}
  res
}

stopCluster(cl)

save(res,file="res/coupled_temp.RData")

# get results into data frame
vals_mat = matrix(0,length(res),length(res[[1]]))
for(a in 1:length(res)){show(res[[a]]);vals_mat[a,]=res[[a]]}
v = data.frame(vals_mat);
colnames(v)=c("lonmin","latmin","moran","distance","entropy","slope","rsquaredslope",
              "pop","max","meanBetweenness","alphaBetweenness",
              "meanCloseness","alphaCloseness",
              "meanLinkLength","networkPerf",
              "meanPathLength","diameter","components","clustCoef",
              "vcount","ecount","networkDensity"
              )


show(paste0("Ellapsed Time : ",proc.time()[3]-startTime))


#gg = ggplot(v)
#gg+geom_raster(aes(x=lonmin,y=latmin,fill=vcount))+scale_color_continuous(low='yellow',high='red')

#
# 
# # store in data file
write.table(
   v,
   file=paste0('res/',purpose,format(Sys.time(), "%a-%b-%d-%H:%M:%S-%Y"),'.csv'),
   sep = ";",
   col.names=colnames(v)
)
# 




