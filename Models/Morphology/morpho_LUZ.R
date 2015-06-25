
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
p = SpatialPolygons(list(luz@polygons[[1]]),proj4string=luz@proj4string)

# extract from raster
e = extract(raw,p,cellnumbers=TRUE)

extractAsMatrix<-function(raw,polygon,nrow,ncol){
  
}
