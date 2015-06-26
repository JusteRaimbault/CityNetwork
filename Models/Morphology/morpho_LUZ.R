
#########
# morphology of urban entities (European LUZ)
#########

# libraries
library(raster)
library(rgdal)

# load data
raw <- raster(paste0(Sys.getenv("CN_HOME"),"/Data/PopulationDensity/raw/popu01clcv5.tif"))
luz <- readOGR(paste0(Sys.getenv("CN_HOME"),"/Data/UrbanAudit/URAU_2004_SH/shape/data"),"URAU_LUZ_RG_03M")

#############
# test on data
length(luz@polygons)
p = SpatialPolygons(list(luz@polygons[[30]]),proj4string=luz@proj4string)
p = SpatialPolygons(luz@polygons,proj4string=luz@proj4string)
p=spTransform(p,raw@crs)
e=extent(p)

r=raster(nrow=floor((e[4]-e[3])/100)+1,ncol=floor((e[2]-e[1])/100)+1);extent(r)=extent(p)
extr<- rasterize(p,r,getCover=TRUE)
o <- overlay(raw,extr,fun=function(d,p)d*p/100)

# extract from raster
e = extract(raw,p,cellnumbers=TRUE)
c=sapply(e[[1]][,1],coordinates,nc=43700)

# get coords of a raster cell given its cell number
coordinates<-function(cellnumber,nc){
  return(c(floor(cellnumber / nc) + 1,cellnumber - nc * floor(cellnumber / nc)))
}

extractAsMatrix<-function(raw,polygon,nr,nc){
  rawVals = extract(raw,p,cellnumbers=TRUE)
}
