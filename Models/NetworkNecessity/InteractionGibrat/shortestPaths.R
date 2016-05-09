
# construct mnt shortest paths
# and corresponding feedback matrix

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/NetworkNecessity/InteractionGibrat'))

library(raster)
library(rgdal)
library(igraph)

mnt <- merge(raster(paste0(Sys.getenv('CN_HOME'),'/Data/BDALTI/BDALTIV2_1000M_FXX_0000_6900_MNT_LAMB93_IGN69.asc')),raster(paste0(Sys.getenv('CN_HOME'),'/Data/BDALTI/BDALTIV2_1000M_FXX_0000_8050_MNT_LAMB93_IGN69.asc')))

prevrow=c();prevnames=c();previnds=c();edf=data.frame();vdf=data.frame()
for(i in 1:nrow(mnt)){
  show(i)
  if(length(which(!is.na(getValuesBlock(mnt,row=i))))>0){
    xcors = xmin(mnt) + (0:(ncol(mnt)-1))*xres(mnt)
    ycor = ymin(mnt) + (nrow(mnt) - i )*yres(mnt)
    vnames=paste0(as.character(xcors),'-',ycor)
    currentrow=getValuesBlock(mnt,row=i);
    inds=which(!is.na(currentrow));#hinds=which()
    vdf=rbind(vdf,data.frame(vnames[inds],xcors[inds],rep(ycor,length(inds))))
    edf=rbind(edf,data.frame(from=vnames[inds[1:(length(inds)-1)]],to=vnames[inds[2:length(inds)]],slope = currentrow[inds[2:length(inds)]]-currentrow[inds[1:(length(inds)-1)]]))  
    edf=rbind(edf,data.frame(from=vnames[inds[2:length(inds)]],to=vnames[inds[1:(length(inds)-1)]],slope = currentrow[inds[1:(length(inds)-1)]]-currentrow[inds[2:length(inds)]]))  
    if(length(prevrow)>0){
      vinds = intersect(inds,previnds)
      edf=rbind(edf,data.frame(from=vnames[vinds],to=prevnames[vinds],slope=prevrow[vinds]-currentrow[vinds]))
      edf=rbind(edf,data.frame(from=prevnames[vinds],to=vnames[vinds],slope=currentrow[vinds]-prevrow[vinds]))
    }
    prevrow=currentrow;prevnames=vnames;previnds=inds
  }
}

names(vdf)<-c("name","x","y")

g=graph_from_data_frame(d = edf,directed=TRUE,vertices = vdf)

