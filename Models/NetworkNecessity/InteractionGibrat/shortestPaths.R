
# construct mnt shortest paths
# and corresponding feedback matrix

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/NetworkNecessity/InteractionGibrat'))

source('functions.R')

library(raster)
library(rgdal)
library(igraph)
library(Matrix)

mnt <- merge(raster(paste0(Sys.getenv('CN_HOME'),'/Data/BDALTI/BDALTIV2_1000M_FXX_0000_6900_MNT_LAMB93_IGN69.asc')),raster(paste0(Sys.getenv('CN_HOME'),'/Data/BDALTI/BDALTIV2_1000M_FXX_0000_8050_MNT_LAMB93_IGN69.asc')))
#writeRaster(x = mnt,filename =paste0(Sys.getenv('CN_HOME'),'/Models/NetworkNecessity/InteractionGibrat/data/mnt.asc'))
#crs(mnt)<-CRS("+init=epsg:2154") #Lambert 93
# 

# prevrow=c();prevnames=c();previnds=c();edf=data.frame();vdf=data.frame()
# for(i in 1:nrow(mnt)){
#   show(i)
#   if(length(which(!is.na(getValuesBlock(mnt,row=i))))>0){
#     xcors = xmin(mnt) + (0:(ncol(mnt)-1))*xres(mnt) + (xres(mnt) / 2)
#     ycor = ymin(mnt) + (nrow(mnt) - i )*yres(mnt) + (yres(mnt) / 2)
#     vnames=paste0(as.character(xcors),'-',ycor)
#     currentrow=getValuesBlock(mnt,row=i);
#     inds=which(!is.na(currentrow));
#     hinds=which(!is.na(currentrow[1:(length(currentrow)-1)])&!is.na(currentrow[2:length(currentrow)]))
#     vdf=rbind(vdf,data.frame(vnames[inds],xcors[inds],rep(ycor,length(inds))))
#     edf=rbind(edf,data.frame(from=vnames[hinds],to=vnames[hinds+1],slope = currentrow[hinds]-currentrow[hinds+1],length=1))  
#     edf=rbind(edf,data.frame(from=vnames[hinds+1],to=vnames[hinds],slope = currentrow[hinds+1]-currentrow[hinds],length=1))  
#     if(length(prevrow)>0){
#       vinds = intersect(inds,previnds)
#       edf=rbind(edf,data.frame(from=vnames[vinds],to=prevnames[vinds],slope=prevrow[vinds]-currentrow[vinds],length=1))
#       edf=rbind(edf,data.frame(from=prevnames[vinds],to=vnames[vinds],slope=currentrow[vinds]-prevrow[vinds],length=1))
#       d1inds = which(!is.na(currentrow[1:(length(currentrow)-1)])&!is.na(prevrow[2:length(prevrow)]))
#       edf=rbind(edf,data.frame(from=vnames[d1inds],to=prevnames[d1inds+1],slope=prevrow[d1inds+1]-currentrow[d1inds],length=sqrt(2)))
#       edf=rbind(edf,data.frame(from=prevnames[d1inds+1],to=vnames[d1inds],slope=currentrow[d1inds]-prevrow[d1inds+1],length=sqrt(2)))
#       d2inds = which(!is.na(prevrow[1:(length(prevrow)-1)])&!is.na(currentrow[2:length(currentrow)]))
#       edf=rbind(edf,data.frame(from=prevnames[d2inds],to=vnames[d2inds+1],slope=currentrow[d2inds+1]-prevrow[d2inds],length=sqrt(2)))
#       edf=rbind(edf,data.frame(from=vnames[d2inds+1],to=prevnames[d2inds],slope=prevrow[d2inds]-currentrow[d2inds+1],length=sqrt(2)))
#     }
#     prevrow=currentrow;prevnames=vnames;previnds=inds
#   }
# }
# 
# names(vdf)<-c("name","x","y")
# 
# g=graph_from_data_frame(d = edf,directed=TRUE,vertices = vdf)

# save the graph
#save(g,file='data/graph_distances.RData')
load('data/graph_distances.RData')


# compute shortest paths for all couples of cities

# - load cities
# - check coordinates
# - get corresponding vertices
# - compute
# - store as {city_i_ID,city_j_ID}->city_k_ID

#Ncities=200
NCities=50
data<-loadData(Ncities)
cities=SpatialPoints(as.matrix(data$cities[,2:3])*100,proj4string = CRS("+init=epsg:27572"))
cities=spTransform(cities,CRS=CRS("+init=epsg:2154"))
coords=coordinates(cities)

#test
#iparis=which(abs(V(g)$x-coordinates(cities)[1,1])<500&abs(V(g)$y-coordinates(cities)[1,2])<500)
#inice=which(abs(V(g)$x-coordinates(cities)[12,1])<500&abs(V(g)$y-coordinates(cities)[12,2])<500)
#p=shortest_paths(g,from=V(g)[iparis],to=V(g)[inice],output="vpath",weights=impedances)$vpath[[1]]
#spplot(mnt,xlim=c(0,1100000),ylim=c(6000000,7100000));
#plot(cities,col='green',add=TRUE);plot(SpatialPoints(matrix(c(p$x,p$y),nrow=length(p),byrow=FALSE),proj4string = CRS("+init=epsg:2154")),col='red',add=TRUE,pch='.')
#spplot(mnt,# scales = list(draw = TRUE),
#       xlim=c(0,1100000),ylim=c(6000000,7150000)#,
    #sp.layout = list(SpatialPoints(matrix(c(p$x,p$y),nrow=length(p),byrow=FALSE)),cities,col=c(rep('red',length(p)),rep('green',length(cities))),pch=c(rep('.',length(p)),rep('+',length(cities))),cex=c(rep(1,length(p)),rep(8,length(cities))))
#)
#plot(cities,col='green',add=TRUE)

dists = feedbackDistMat(g,coords)

save(dists,file=paste0('data/distMat_Ncities',Ncities,'_alpha0',alpha0,'_n0',n0,'.RData'))


