
# direct simplification

#
# assumes a full osmdb ; cuts it into coords bbox,
#   parallelized in a parfor loop
#

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))

source('nwSimplFunctions.R')

densraster <- raster(paste0(Sys.getenv("CN_HOME"),"/Data/PopulationDensity/raw/density_wgs84.tif"))
#latmin=extent(densraster)@ymin;latmax=extent(densraster)@ymax;
#lonmin=extent(densraster)@xmin;lonmax=extent(densraster)@xmax
latmin=46.34;latmax=48.94;lonmin=0.0;lonmax=3.2

ncells = 500
#rows = seq(from=1,to=nrow(densraster),by=ncells)
#cols = seq(from=1,to=ncol(densraster),by=ncells)
rows = seq(from=rowFromY(densraster,latmax),to=rowFromY(densraster,latmin),by=ncells)
cols = seq(from=colFromX(densraster,lonmin),to=colFromX(densraster,lonmax),by=ncells)
xr=xres(densraster);yr=yres(densraster)

coords = data.frame()
for(i in 2:length(rows)){
  for(j in 2:length(cols)){
    topleft = xyFromCell(densraster,cellFromRowCol(densraster,rows[i-1],cols[j-1]))
    bottomright = xyFromCell(densraster,cellFromRowCol(densraster,rows[i],cols[j]))
    coords = rbind(coords,c(topleft[1]-xr/2,topleft[2]+yr/2,bottomright[1]+xr/2,bottomright[2]-yr/2))
  }
}
names(coords)<-c("lonmin","latmax","lonmax","latmin")
tags=c("motorway","trunk","primary","secondary","tertiary")

library(doParallel)
cl <- makeCluster(10)
registerDoParallel(cl)

startTime = proc.time()[3]

res <- foreach(i=1:nrow(coords)) %dopar% {
  osmdb='centre';dbport=5433
  source('nwSimplFunctions.R')
  lonmin=coords[i,1];lonmax=coords[i,3];latmin=coords[i,4];latmax=coords[i,2]
  roads<-linesWithinExtent(lonmin,latmin,lonmax,latmax,tags)
  return(length(roads@roads))
}

stopCluster(cl)

show(res)









