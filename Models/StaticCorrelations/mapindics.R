
setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))

library(raster)
library(ggplot2)
library(dplyr)
library(rgdal)
library(rgeos)
library(reshape2)
library(cartography)
library(classInt)

source('functions.R')
source('mapFunctions.R')

# load data
res = loadIndicatorData("res/res/europe_areasize100_offset50_factor0.5_20160824.csv") # Europe
#res = loadIndicatorData('res/chinacoupled_areasize100_offset50_factor0.1_temp.RData') # China

# load spatial mask to select area
countries = readOGR('gis','countries')
country = countries[countries$CNTR_ID=="FR",]

datapoints = SpatialPoints(data.frame(res[,c("lonmin","latmin")]),proj4string = countries@proj4string)

selectedpoints = gContains(country,datapoints,byid = TRUE)
sdata = res[selectedpoints,]
#sdata=res

# map indicators
#g=ggplot(sdata,aes(x=lonmin,y=latmin,fill=cut(moran,breaks=10)))
#g+geom_raster()+scale_fill_brewer(palette = "Spectral")+theme_bw()

resdir = paste0(Sys.getenv('CN_HOME'),'/Results/StaticCorrelations/Morphology/Coupled/Maps/CN/')
dir.create(resdir)

map(c(8),'test3.png',20,12,c(1,1))

# morpho
#map(c(3,4,5,6),'indics_morpho.png',20,18,c(2,2)) # FR
#map(c(3,4,5,6),'indics_morpho.png',20,20,c(2,2)) # UK
map(c(8,9,10,6),'indics_morpho.png',40,22,c(2,2)) # CN

# all morpho
#map(c(3,4,5,6,7,8),'indics_morpho_all_discrquantiles.png',32,18,c(2,3),mar=c(2.5,2.5,1.5,6)) # FR
#map(c(3,4,5,6,7,8),'indics_morpho_all.png',32,20,c(2,3),mar=c(2.5,2.5,1.5,6)) # UK
map(3:10,'indics_morpho_all.png',40,22,c(3,3),mar=c(2.5,2.5,1.5,6)) # CN



# all network
#map(c(10:20,22),'indics_network_all.png',44,30,c(3,4),mar=c(2.5,2.5,1.5,6)) # FR
#map(c(10:20,22),'indics_network_all.png',44,32,c(3,4),mar=c(2.5,2.5,1.5,6)) # UK
map(c(11:31),'indics_network_all.png',60,40,c(7,3),mar=c(2.5,2.5,1.5,6)) # CN


# selected network
#map(c(10,15,19,20),'indics_network_selected.png',22,18,c(2,2),mar=c(2.5,2,1.5,7.5))
#map(c(10,13,19,20),'indics_network_selected_2.png',22,18,c(2,2),mar=c(2.5,2,1.5,7.5))
map(c(11,26,29,23),'indics_network_selected.png',40,22,c(2,2),mar=c(2.5,2,1.5,7.5))


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



######
# scale extracted through GWRPCA

library(GWmodel)

# select full data
sdata = sdata[apply(sdata,1,function(r){ifelse(length(which(is.na(r)))>0,F,T)}),]
#data = sdata[sapply(sdata$lonmin,function(x){x%in%sdata$lonmin[seq(from=1,to=length(unique(sdata$lonmin)),by=2)]}),]
#data = data[sapply(data$latmin,function(x){x%in%data$latmin[seq(from=1,to=length(unique(data$latmin)),by=2)]}),]
#map(indiccols = c(3,4),sdata=sdata,mfrow=c(1,2))

# sample for speed (and to have locally independant observation)

data=sdata[sample.int(nrow(sdata),size=5000,replace = F),]
#data=sdata

points = SpatialPointsDataFrame(coords=data.frame(data[,c("lonmin","latmin")]),data.frame(data),match.ID=F,proj4string = countries@proj4string)
#points = SpatialPointsDataFrame(coords=data.frame(sdata[,c("lonmin","latmin")]),data.frame(sdata[,c("moran","distance","entropy","slope")]),match.ID=F,proj4string = countries@proj4string)


# test
pca = gwpca(points,vars=c("moran","distance","entropy","slope"),bw=2)

map(indiccols = c(3,4),sdata=data.frame(data[,c("lonmin","latmin")],pca$var),mfrow=c(1,2))

# optimal bw for morphology
bw <- bw.gwpca(points,vars=c("moran","distance","entropy","slope"),k=2,adaptive = T)
pca = gwpca(points,vars=c("moran","distance","entropy","slope"),bw=bw,adaptive = T)
map(indiccols = c(3,4),sdata=data.frame(data[,c("lonmin","latmin")],pca$var),mfrow=c(1,2))

#
bw <- bw.gwpca(points,vars=c("moran","slope","meanBetweenness","alphaCloseness"),k=2,adaptive = T)

pca = gwpca(points,vars=c("moran","slope","meanBetweenness","alphaCloseness"),bw=bw,adaptive = T)

# quite shitty..
# try some regressions ?
# -> gwr will reveal different scales depending on process !

map(indiccols = c(3,4),sdata=data.frame(data[,c("lonmin","latmin")],pca$var),mfrow=c(1,2))


###
## Find endogenous scales with gwr
#

getLinearModels("meanBetweenness",c("moran","distance","entropy","slope"),4)

bw = bw.gwr("meanBetweenness~slope+moran",data=points,approach = 'AIC')
gwr = gwr.basic("meanBetweenness~slope+moran",data=points,bw=bw)













