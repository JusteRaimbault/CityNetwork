setwd(paste0(Sys.getenv('CN_HOME'),'/Models/MesoCoevol/analysis'))

library(dplyr)
library(ggplot2)
library(rgdal)
library(rgeos)
library(raster)

source('../MesoCoevol/r/morpho.R')

# real data
raw=read.csv(file=paste0(Sys.getenv('CN_HOME'),"/Models/StaticCorrelations/res/res/europe_areasize100_offset50_factor0.5_20160824.csv"),sep=";",header=TRUE)
rows=apply(raw,1,function(r){prod(as.numeric(!is.na(r)))>0})
res=as.tbl(raw[rows,])


#g=ggplot(res,aes(x=pop,y=ecount))
#g+geom_point(pch='.')+geom_smooth()
summary(lm(data=res,ecount~pop))
summary(lm(data=res,vcount~pop))
summary(lm(data=res,meanLinkLength~pop))
summary(lm(data=res,meanLinkLength~ecount))
summary(lm(data=res,meanPathLength~pop))
cor(res$pop,res$meanLinkLength)
cor(res$meanLinkLength,res$ecount)
cor(res$ecount,res$pop)


# -> ecount = a*pop + b

##
# selection of grids

countries = readOGR('gis','countries')
country = countries[countries$CNTR_ID=="FR",]

datapoints = SpatialPoints(data.frame(res[,c("lonmin","latmin")]),proj4string = countries@proj4string)

selectedpoints = gContains(country,datapoints,byid = TRUE)
sdata = res[selectedpoints,]
rm(raw,res);gc()

sdata=sdata[apply(sdata,1,function(r){prod(as.numeric(!is.na(r)))>0}),]
cdata=sdata
# normalize columns
for(j in 3:ncol(cdata)){cdata[,j]<-(cdata[,j]-min(cdata[,j]))/(max(cdata[,j])-min(cdata[,j]))}

set.seed(0)

k=5
m=cdata[cdata$pop<0.063&cdata$pop>0,c("moran","distance","entropy","slope","rsquaredslope")]
km = kmeans(m,k,iter.max = 1000,nstart=100)
cluster = km$cluster

# draw 10 random grids in each cluster
rows=c()
for(kk in 1:k){rows = append(rows,sample(which(cluster==kk),size = 10,replace = F))}

#gridcaracs = sdata[cdata$pop<0.063&cdata$pop>0,][rows,]
gridcaracs=sdata[rows,]

rasterfile=paste0(Sys.getenv('CN_HOME'),'/Data/PopulationDensity/raw/density_wgs84.tif')
densraster=raster(rasterfile)

confcols = colFromX(densraster,x=gridcaracs$lonmin)
confrows = rowFromY(densraster,y=gridcaracs$latmin)
size=100;factor=0.5

for(i in 1:length(confcols)){
  show(i)
  conf=extractSubRaster(rasterfile,r =confrows[i],c= confcols[i] ,size=size,factor = factor)
  write.table(conf,file=paste0('../MesoCoevol/setup/fixeddensity/',i),row.names = F,col.names = F,sep=';')
}

# writes caracs
write.table(data.frame(gridcaracs,rows=rows),sep=";",row.names = F,col.names = T,file='../MesoCoevol/setup/fixeddensity/grids.csv')


# ecount = f(pop)
summary(gridcaracs$ecount)
summary(lm(data=gridcaracs,ecount~pop))


# real morph caracs of cluster centers
m = sdata[cdata$pop<0.063&cdata$pop>0,c("moran","distance","entropy","slope","rsquaredslope")]
m$cluster=cluster
centroids = m%>%group_by(cluster)%>%summarise(moran=mean(moran),distance=mean(distance),entropy=mean(entropy),slope=mean(slope),rsquaredslope=mean(rsquaredslope))
# find real cluster by distance to centroids
gridcaracs$cluster = apply(gridcaracs[,c("moran","distance","entropy","slope","rsquaredslope")],1,function(r){
  which.min(rowSums((centroids[,2:6]-matrix(rep(r,5),nrow=5,byrow=T))^2))
})

write.table(gridcaracs,sep=";",row.names = F,col.names = T,file='../MesoCoevol/setup/fixeddensity/grids_clust.csv')





