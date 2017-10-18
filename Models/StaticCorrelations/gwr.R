
# gwr

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))

library(raster)
library(dplyr)
library(rgdal)
library(rgeos)
library(reshape2)
library(GWmodel)

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
sdata = sdata[apply(sdata,1,function(r){ifelse(length(which(is.na(r)))>0,F,T)}),]

morphoindics = c("moran","distance","entropy","slope")
networkIndics = c("meanBetweenness","meanCloseness","networkPerf","vcount")
nbootstrap = 25
#nbootstrap = 1
models=c();
for(morphoindic in morphoindics){
  currentmodels = getLinearModels(morphoindic,networkIndics,length(networkIndics))
  models = append(models,rep(currentmodels,nbootstrap))
}
for(networkIndic in networkIndics){
  currentmodels = getLinearModels(networkIndic,morphoindics,length(morphoindics))
  models = append(models,rep(currentmodels,nbootstrap))
}


library(doParallel)
cl <- makeCluster(25,outfile='loggwr')
registerDoParallel(cl)

resgwr <- foreach(i=1:length(models)) %dopar% {
  library(GWmodel);library(sp);set.seed(i)
  currentmodel = models[i]
  show(paste0('Model ',i,' : ',currentmodel))
  data=sdata[sample.int(nrow(sdata),size=5000,replace = F),]
  #data=sdata
  points = SpatialPointsDataFrame(coords=data.frame(data[,c("lonmin","latmin")]),data.frame(data),match.ID=F,proj4string = countries@proj4string)
  bw = bw.gwr(currentmodel,data=points,approach = 'AIC',adaptive = T)
  gw = gwr.basic(currentmodel,data=points,bw=bw,adaptive = T)
  d=spDists(points,longlat = T)
  meandist = mean(apply(d,1,function(r){mean(sort(r[r>0])[1:bw])}))
  return(list(bw=bw,meandist=meandist,aic = gw$GW.diagnostic$AICc,r2=gw$GW.diagnostic$gwR2.adj,model=currentmodel,indic=strsplit(currentmodel,split='~')[[1]][1]))
}

save(resgwr,file='res/gwr_full.RData')


###############
## analysis
# 
# load('res/gwr.RData')
# 
# d = data.frame(bw=sapply(resgwr,function(l){l$bw}),
#                meandist=sapply(resgwr,function(l){l$meandist}),
#                aic=sapply(resgwr,function(l){l$aic}),
#                model=sapply(resgwr,function(l){l$model}),
#                indic=sapply(resgwr,function(l){l$indic})
#                )
# 
# sres = as.tbl(d)%>%group_by(model,indic)%>%summarise(dist=mean(meandist),bw=mean(bw),distsd=sd(meandist),aicsd=sd(aic),aic=mean(aic))
# 
# bestmodels = sres%>%group_by(indic)%>%summarise(bestmodel=model[which(aic==min(aic))],dist=dist[which(aic==min(aic))],bw=bw[which(aic==min(aic))])
# 
# data=sdata
# points = SpatialPointsDataFrame(coords=data.frame(data[,c("lonmin","latmin")]),data.frame(data),match.ID=F,proj4string = countries@proj4string)
# 
# 
# for(i in 1:nrow(bestmodels)){
#   gw = gwr.basic(as.character(bestmodels$bestmodel)[i],data=points,bw=floor(bestmodels$bw[i]),adaptive = T)
# 
# }



###
## test : distance matrix

# data=sdata
# points = SpatialPointsDataFrame(coords=data.frame(data[,c("lonmin","latmin")]),data.frame(data),match.ID=F,proj4string = countries@proj4string)
# 
# lon = sort(unique(data$lonmin));lat=sort(unique(data$latmin))
# lonsample = lon[seq(from=5,to=length(lon),by=10)];latsample=lat[seq(from=5,to=length(lat),by=10)]
# calib = matrix(c(c(matrix(rep(lonsample,length(latsample)),nrow = length(latsample),byrow = T)),rep(latsample,length(lonsample))),ncol = 2,byrow = F)
# 
# dmat = gw.dist(points@coords,calib,longlat = T)
# 
# gw = gwr.basic(meanCloseness~distance+entropy,data=points,bw=271,adaptive = T,dMat = dmat)
# 




