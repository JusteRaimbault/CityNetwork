
convertCSV<-function(UIR){
  library(raster)
  # convert raw csv files to rasters
  #setwd(paste0(Sys.getenv("CN_HOME"),'/Models/Synthetic/Density')) # not needed
  d=as.matrix(read.table(paste0('tmp/temp_pop_',UIR,'.csv'),header=FALSE,sep=';'))
  rpop = raster(d)
  rdens = raster(d/sum(d))

  writeRaster(rpop,paste0('tmp/temp_raster_pop_',UIR,'.asc'),overwrite=TRUE)
  writeRaster(rdens,paste0('tmp/temp_raster_dens_',UIR,'.asc'),overwrite=TRUE)
}


exportIndics<-function(UIR){
  convertCSV(UIR)
  rpop_file=paste0('tmp/temp_raster_pop_',UIR,'.asc')
  rdens_file=paste0('tmp/temp_raster_dens_',UIR,'.asc')
  source('morpho.R',local=TRUE)
  
  s=rankSizeSlope()
  write.table(data.frame(moran=moranIndex(),distance=averageDistance(),entropy=entropy(),slope=s[1],rsquared=s[2])
              ,file=paste0('tmp/temp_indics_',UIR,'.csv')
              ,row.names=FALSE,sep=';',quote=FALSE
  )
}

