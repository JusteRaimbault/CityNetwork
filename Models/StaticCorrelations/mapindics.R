
setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))
source('functions.R')

library(raster)
library(ggplot2)
library(dplyr)
library(rgdal)
library(rgeos)

# load data
raw=read.csv(file="res/res/europe_areasize100_offset50_factor0.5_20160824.csv",sep=";",header=TRUE)
rows=apply(raw,1,function(r){prod(as.numeric(!is.na(r[c(1,2)])))>0})
#rows=1:length(raw)
res=as.tbl(raw[rows,])


# load spatial mask to select area
countries = readOGR('gis','countries')
country = countries[countries$CNTR_ID=="FR",]

datapoints = SpatialPoints(data.frame(res[,c("lonmin","latmin")]),proj4string = countries@proj4string)

selectedpoints = gContains(country,datapoints,byid = TRUE)
sdata = res[selectedpoints,]

# map indicators
g=ggplot(sdata,aes(x=lonmin,y=latmin,fill=cut(moran,breaks=10)))
g+geom_raster()+scale_fill_brewer(palette = "Spectral")+theme_bw()


#####
# clusterings

sdata=sdata[apply(sdata,1,function(r){prod(as.numeric(!is.na(r)))>0}),]

knums=2:15
indics = c("moran","distance","entropy","slope","rsquaredslope","pop","max")

ccoef=c()
for(k in knums){
  show(k)
  km = kmeans(sdata[,indics],k,iter.max = 1000,nstart=100)
  ccoef=append(ccoef,km$betweenss/km$totss);
}

g=ggplot(data.frame(knums=knums[1:length(ccoef)],ccoef=ccoef),aes(x=knums,y=ccoef))
g+geom_point()+geom_line()

g=ggplot(data.frame(knums=knums[2:length(ccoef)],dccoef=diff(ccoef)),aes(x=knums,y=dccoef))
g+geom_point()+geom_line()

# plot clusters map

km = kmeans(sdata[,indics],5,iter.max = 1000,nstart=100)

sdata$cluster = as.character(km$cluster)

g=ggplot(sdata,aes(x=lonmin,y=latmin,fill=cluster))
g+geom_raster()+theme_bw()

