


library(raster)




# aggregate by resFactor (resolution = resolution * resFactor)
# a given square matrix of size areasize
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




# function to extract square subraster of a large raster
# used for visualisation of parts as real config
# - stored as temp asc file
extractSubRaster<- function(file,r,c,size,factor){
  raw <- raster(file)
  return(data.frame(simplifyBlock(getValuesBlock(raw,row=r,nrows=size,col=c,ncols=size),factor,size)/100))
  #r<-setExtent(r,extent(raster(paste0(Sys.getenv("CN_HOME"),'/Models/Synthetic/Density/temp_raster_pop.asc'))))
  #writeRaster(r,paste0(Sys.getenv("CN_HOME"),'/Models/Synthetic/Density/temp_raster_pop.asc'),format="ascii",overwrite=TRUE)
}

getCoordinates<-function(file,r,c){
  raw <- raster(file)
  return(spTransform(xyFromCell(raw,cellFromRowCol(raw,rownr = r,colnr = c),spatial = T),CRS("+proj=longlat +datum=WGS84")))
}


writeTempRaster<-function(){
  rasterfile=paste0(Sys.getenv('CN_HOME'),'/Data/PopulationDensity/raw/popu01clcv5.tif')
  coords=read.csv('setup/coordstmp.csv')
  xcor=coords[1,1];ycor=coords[1,2]
  #conf=extractSubRaster(rasterfile,r = xcor ,c=ycor,size=250,factor = 0.2)
  conf=extractSubRaster(rasterfile,r = xcor ,c=ycor,size=500,factor = 0.1)
  write.table(conf,file='setup/conftmp.csv',row.names = F,col.names = F,sep=';')
}




