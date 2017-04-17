
setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))
source('functions.R')

library(raster)
library(ggplot2)
library(dplyr)
library(rgdal)
library(rgeos)
library(reshape2)
library(cartography)
library(classInt)

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


resdir = paste0(Sys.getenv('CN_HOME'),'/Results/Morphology/Coupled/Maps/')

y=function(x){log(x+0.01)};yinv = function(y){exp(y)-0.01}
map<-function(indiccols,filename,width,height,mfrow,mar=c(2,2.5,1.5,2) + 0.1){
  png(file=paste0(resdir,filename),width=width,height=height,units='cm',res=600)
  par(mfrow=mfrow ,mar = mar,
      oma = c(0,0,0,1) + 0.1)
  cols <- carto.pal(pal1 = "green.pal",n1 = 5, pal2 = "red.pal",n2 = 5)
  for(indic in indiccols){
    #x = y(unlist(sdata[,indic]))
    x = unlist(sdata[,indic])
    m=acast(data.frame(sdata[,c(1,2)],x),latmin~lonmin);r = raster(m[seq(from=nrow(m),to=1,by=-1),])
    crs(r)<-"+proj=longlat +datum=WGS84";extent(r)<-c(min(sdata$lonmin),max(sdata$lonmin),min(sdata$latmin),max(sdata$latmin))
    breaks=classIntervals(x,10)
    #ticks = yinv(seq(round(minValue(r),digits=1),round(maxValue(r),digits=1), round((round(maxValue(r),digits=2) - round(minValue(r),digits=2))/5,digits=1)))
    ticks = seq(round(minValue(r),digits=1),round(maxValue(r),digits=1), round((round(maxValue(r),digits=2) - round(minValue(r),digits=2))/5,digits=1))
    plot(r,main=colnames(sdata)[indic],
         col=cols,breaks=unique(breaks$brks),
         legend.width = 1.5,
         axis.args=list(at=ticks,labels=ticks,cex.axis=1.0)
         )
  }
  dev.off()
}
map(c(22),'test3.png',12,10,c(1,1))

# morpho
map(c(3,4,5,6),'indics_morpho_discrquantiles.png',20,18,c(2,2))

# all morpho
map(c(3,4,5,6,7,8),'indics_morpho_all_discrquantiles.png',32,18,c(2,3),mar=c(2.5,2.5,1.5,6))

# all network
map(c(10:20,22),'indics_network_all_discrquantiles.png',44,30,c(3,4),mar=c(2.5,2.5,1.5,6))

# selected network
map(c(10,15,19,20),'indics_network_selected_discrquantiles.png',22,18,c(2,2),mar=c(2.5,2,1.5,7.5))


#####
# clusterings

indics = list(
   morpho = c("moran","distance","entropy","slope","rsquaredslope"),
   morphopop = c("moran","distance","entropy","slope","rsquaredslope","pop","max"),
   network = c("meanBetweenness","alphaBetweenness","meanCloseness","alphaCloseness","meanLinkLength","networkPerf","meanPathLength","diameter" ,"components" ,"clustCoef" ,"vcount", "ecount","networkDensity"),
   full = c("moran","distance","entropy","slope","rsquaredslope","meanBetweenness","alphaBetweenness","meanCloseness","alphaCloseness","meanLinkLength","networkPerf","meanPathLength","diameter" ,"components" ,"clustCoef" ,"vcount", "ecount","networkDensity"),
   fullpop = c("moran","distance","entropy","slope","rsquaredslope","pop","max","meanBetweenness","alphaBetweenness","meanCloseness","alphaCloseness","meanLinkLength","networkPerf","meanPathLength","diameter" ,"components" ,"clustCoef" ,"vcount", "ecount","networkDensity")
)
  
cdata=sdata[apply(sdata,1,function(r){prod(as.numeric(!is.na(r)))>0}),]
# normalize columns
for(j in 3:ncol(cdata)){cdata[,j]<-(cdata[,j]-min(cdata[,j]))/(max(cdata[,j])-min(cdata[,j]))}

summary(prcomp(cdata[,indics$morpho]))
summary(prcomp(cdata[,indics$morphopop]))
summary(prcomp(cdata[,indics$network]))
summary(prcomp(cdata[,indics$full]))
summary(prcomp(cdata[,indics$fullpop]))

knums=2:12

ccoef=c();cknums=c();types=c();dccoef=c();dcknums=c();dtypes=c()
for(type in names(indics)){
  show(type)
  for(k in knums){
    show(k)
    km = kmeans(cdata[,indics[[type]]],k,iter.max = 1000,nstart=100)
    ccoef=append(ccoef,km$betweenss/km$totss);types=append(types,type);cknums=append(cknums,k)
  }
  dccoef=append(dccoef,diff(ccoef[(length(ccoef)-length(knums)+1):length(ccoef)]));
  dcknums=append(dcknums,knums[2:length(knums)]);dtypes=append(dtypes,rep(type,length(knums)-1))
}

g=ggplot(data.frame(knums=cknums,ccoef=ccoef,type=types),aes(x=knums,y=ccoef,color=type,group=type))
g+geom_point()+geom_line()+xlab("Number of clusters")+ylab("Inter-cluster variance proportion")
ggsave(paste0(resdir,'cluster_betweenvar.pdf'),width=15,height=10,units = 'cm')

g=ggplot(data.frame(knums=dcknums,dccoef=dccoef,type=dtypes),aes(x=knums,y=dccoef,color=type,group=type))
g+geom_point()+geom_line()+xlab("Number of clusters")+ylab("Inter-cluster variance proportion increase")
ggsave(paste0(resdir,'cluster_betweenvarincr.pdf'),width=15,height=10,units = 'cm')

# plot clusters map and cluster in PC plan

k=5
for(type in names(indics)){
  m=cdata[,indics[[type]]]
  km = kmeans(m,k,iter.max = 1000,nstart=100)
  cluster = as.character(km$cluster)
  
  g=ggplot(cdata,aes(x=lonmin,y=latmin,fill=cluster))
  g+geom_raster()+theme_bw()+xlab('')+ylab('')
  ggsave(paste0(resdir,'cluster_map_k',k,'_',type,'.png'),width=18,height=15,units='cm')
  
  pca = prcomp(m)
  rotated = as.matrix(m)%*%pca$rotation
  
  g=ggplot(data.frame(rotated,cluster),aes(x=PC1,y=PC2,color=cluster))
  g+geom_point(size=0.5)+ggtitle(paste0('Cumulated variance : ',round(summary(pca)$importance[3,2],digits = 2)))
  ggsave(paste0(resdir,'cluster_pca_k',k,'_',type,'.pdf'),width=17,height=15,units='cm')
  
}









