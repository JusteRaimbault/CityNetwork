
#############
# computation of real values of indicators on large grid on all europe
#############

library(raster)

setwd(paste0(Sys.getenv("CN_HOME"),'/Models/Synthetic/Density'))

# to avoid bord effects dur to grid offset, takes "many" origin phases to setup the grid
# (not too much -- perfs issues)

# use raster package

# first source indicators

source('morpho.R')


# load all europe raster
# Q : size of grid ? -> synthetic datasets are 101x101 rasters

raw <- raster(paste0(Sys.getenv("CN_HOME"),"/Data/PopulationDensity/raw/popu01clcv5.tif"))
#raw <- raster(paste0(Sys.getenv("CN_HOME"),"/Data/PopulationDensity/raw/france.tif"))

# initial raster is 100mx100m -> grid of 100x100 give 10kmx10km areas
# more consistent with a 100kmx100km area ?



simplifyBlock<-function(data,resFactor,areasize){
  m = matrix(data=data,nrow=areasize,byrow=TRUE)
  m[is.na(m)] <- 0
  res=matrix(0,areasize*resFactor,areasize*resFactor)
  for(x in 1:(areasize*resFactor)){
    for(y in 1:(areasize*resFactor)){
      res[x,y]=sum(m[((x-1)/resFactor+1):(x/resFactor),((y-1)/resFactor+1):(y/resFactor)])
    }
  }
  return(res)
}


# -----------------
# -- Experiments --

# 1) computation on all europe (simplified block 100kmx100km)
# 2) France with 20kmx20km, including offset of 2km to avoid bord effects
# 3) Europe 50km with 10km offset (22h max computation with 16 cores)
# 4) Frce 50km


areasize = 500
factor=0.2
offset = 100

xvals=seq(from=1,to=nrow(raw)-areasize,by=offset)
yvals=seq(from=1,to=ncol(raw)-areasize,by=offset)
#TEST //
#xvals=seq(from=5000,to=5200,by=offset)
#yvals=seq(from=5000,to=5200,by=offset)

# coord matrix
coords = matrix(data=c(rep(xvals,length(yvals)),c(sapply(yvals,rep,length(xvals)))),nrow=length(xvals)*length(yvals))
coords=coords[125798:125800,]

# create // cluster
library(doParallel)
cl <- makeCluster(4)
registerDoParallel(cl)

startTime = proc.time()[3]

res <- foreach(i=1:nrow(coords)) %dopar% {
   library(raster)
   source('morpho.R')
   x=coords[i,1];y=coords[i,2];
   e<-getValuesBlock(raw,row=x,nrows=areasize,col=y,ncols=areasize)
   if(sum(is.na(e))/length(e)<0.5){
     show("computing indicators...")
     m=simplifyBlock(e,factor,areasize)
     r_pop = raster(m/100)
     r_dens = raster(m/sum(m))
     res=c(x,y,moranIndex(),averageDistance(),entropy(),rankSizeSlope(),cellStats(r_pop,'sum'))
   }
   else{res=c(x,y,NA,NA,NA,NA,NA)}
   res
}

stopCluster(cl)


# get results into data frame
vals_mat = matrix(0,length(res),length(res[[1]]))
for(a in 1:length(res)){vals_mat[a,]=res[[a]]}
v = data.frame(vals_mat);colnames(v)=c("x","y","moran","distance","entropy","slope","pop")


show(paste0("Ellapsed Time : ",proc.time()[3]-startTime))

# store in data file
write.table(
  v,
  file=paste0(Sys.getenv("CN_HOME"),'/Results/Synthetic/Density/RealData/Numeric/europe_50km_',format(Sys.time(), "%a-%b-%d-%H:%M:%S-%Y"),'.csv'),
  sep = ";",
  col.names=colnames(v)
)






