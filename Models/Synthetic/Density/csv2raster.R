
library(raster)
# convert raw csv files to rasters
setwd(paste0(Sys.getenv("CN_HOME"),'/Models/Synthetic/Density'))
d=as.matrix(read.table('temp_pop.csv',header=FALSE,sep=';'))
rpop = raster(d)
rdens = raster(d)

writeRaster(rpop,'temp_raster_pop.asc',overwrite=TRUE)
writeRaster(rdens,'temp_raster_dens.asc',overwrite=TRUE)



