
# reprojection of population density raster
#  -> WGS 84 for compatibility of coordinates with

setwd(paste0(Sys.getenv('CN_HOME'),'/Data/PopulationDensity'))

library(raster)
library(rgdal)

#raw <- raster('raw/density_wgs84.tif') #issue : should not take 8G
show('Loading raster...')
raw <- raster('raw/popu01clcv5.tif')

wgs84="+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

# reproject
show('Reprojecting...')
reprojected <- projectRaster(from=raw,crs=wgs84)

# write to file
show('Exporting to file...')
writeRaster(reprojected, filename='raw/density_wgs84.tif',format='GTiff')

