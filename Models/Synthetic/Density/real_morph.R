
#############
# computation of real values of indicators on large grid on all europe
#############

setwd(paste0(Sys.getenv("CN_HOME"),'/Models/Synthetic/Density'))

# to avoid bord effects dur to grid offset, takes "many" origin phases to setup the grid
# (not too much -- perfs issues)

# use raster package

# first source indicators

source('morpho.R')


# load all europe raster
# Q : size of grid ? -> synthetic datasets are 101x101 rasters

raw <- raster(paste0(Sys.getenv("CN_HOME"),"/Data/PopulationDensity/raw/popu01clcv5.tif"))

# test extraction
e <- extract(raw,extent(3000000,3010000,1000000,1010000))

# initial raster is 100mx100m -> grid of 100x100 give 10kmx10km areas
# more consistent with a 100kmx100km area ?

# anyway test different aggregation scales
# -> treatment with qgis (or rgdal) ?
# ok here using resolution ?

# res in meters
resolution = 1000
res(raw) <- c(resolution,resolution)

# incells
areasize <- 1000

# extract a 100kmx100km area
e <- extract(raw,extent(3000000,3100000,1000000,1100000))

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

vals = list()
i=1
for(x in seq(from=1,to=nrow(raw)-areasize,by=areasize)){
  for(y in seq(from=1,to=ncol(raw)-areasize,by=areasize)){
     show(paste(x,y))
     #e <- extract(raw,extent(x,x+areasize-1,y,y+areasize-1))
     e<-getValuesBlock(raw,row=x,nrows=areasize,col=y,ncols=areasize)
     # compute on areas with at least half not NA
     if(sum(is.na(e))/length(e)<0.5){
       show("computing indicators...")
       #getting rasters
       m=simplifyBlock(e,0.1,areasize)
       r_pop = raster(m)
       r_dens = raster(m/sum(m))
       vals[[i]]=c(x,y,moranIndex(),averageDistance(),entropy(),rankSizeSlope())
       i=i+1
     }
  }
}




