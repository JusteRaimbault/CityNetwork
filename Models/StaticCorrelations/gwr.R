
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
indics = c(morphoindics,networkIndics)
#nbootstrap = 25
nbootstrap = 1
models=c();
for(morphoindic in morphoindics){
  currentmodels = getLinearModels(morphoindic,networkIndics,length(networkIndics))
  models = append(models,rep(currentmodels,nbootstrap))
}
for(networkIndic in networkIndics){
  currentmodels = getLinearModels(networkIndic,morphoindics,length(morphoindics))
  models = append(models,rep(currentmodels,nbootstrap))
}

data=sdata
points = SpatialPointsDataFrame(coords=data.frame(data[,c("lonmin","latmin")]),data.frame(data),match.ID=F,proj4string = countries@proj4string)
coords = points@coords
dmat = gw.dist(dp.locat = coords,coords)


library(doParallel)
cl <- makeCluster(30,outfile='loggwr')
registerDoParallel(cl)

resgwr <- foreach(i=1:length(models)) %dopar% {
  library(GWmodel);library(sp);set.seed(i)
  currentmodel = models[i]
  show(paste0('Model ',i,' : ',currentmodel))
  #data=sdata[sample.int(nrow(sdata),size=5000,replace = F),]
  #data=sdata
  #points = SpatialPointsDataFrame(coords=data.frame(data[,c("lonmin","latmin")]),data.frame(data),match.ID=F,proj4string = countries@proj4string)
  bw = bw.gwr(currentmodel,data=points,dMat = dmat,approach = 'AIC',adaptive = T)
  gw = gwr.basic(currentmodel,data=points,bw=bw,dMat = dmat,adaptive = T)
  d=spDists(points,longlat = T)
  meandist = mean(apply(d,1,function(r){mean(sort(r[r>0])[1:bw])}))
  gc()
  return(list(bw=bw,meandist=meandist,aic = gw$GW.diagnostic$AICc,r2=gw$GW.diagnostic$gwR2.adj,model=currentmodel,indic=strsplit(currentmodel,split='~')[[1]][1]))
}

#save(resgwr,file='res/gwr_full.RData')
save(resgwr,file='res/gwr_allpoints.RData')

# 
# ###############
# ## analysis
# # 
load('res/gwr_allpoints.RData')

d = as.tbl(data.frame(bw=sapply(resgwr,function(l){l$bw}),
               meandist=sapply(resgwr,function(l){l$meandist}),
               aic=sapply(resgwr,function(l){l$aic}),
               R2=sapply(resgwr,function(l){l$r2}),
               model=sapply(resgwr,function(l){l$model}),
               indic=sapply(resgwr,function(l){l$indic})
               ))

# # distrib of aics across models for one indic
#g=ggplot(d[d$indic=='slope',],aes(x=model,y=aic))
#g+geom_boxplot()
# makes no sense without bootstrap

 
#sres = d%>%group_by(model,indic)%>%summarise(dist=mean(meandist),bw=mean(bw),distsd=sd(meandist),aicsd=sd(aic),aic=mean(aic))
# 
# # tentative with min over all bootstraps - wrong but to see what happens
# #bestmodels =d%>%group_by(indic)%>%summarise(bestmodel=model[which(aic==min(aic))],dist=meandist[which(aic==min(aic))],bw=bw[which(aic==min(aic))])
# 
#bestmodels = sres%>%group_by(indic)%>%summarise(bestmodel=model[which(aic-aicsd==min(aic-aicsd))],dist=dist[which(aic-aicsd==min(aic-aicsd))],bw=bw[which(aic-aicsd==min(aic-aicsd))])
bestmodels = d%>%group_by(indic)%>%summarise(bestmodel=model[which(aic==min(aic))],dist=meandist[which(aic==min(aic))],bw=bw[which(aic==min(aic))],R2=R2[which(aic==min(aic))])

# 
# # use akaike weights
for(indic in indics){
dd = d[d$indic==indic,]
#dd = sres[sres$indic==indic,]
dd$weight = exp(-(dd$aic-min(dd$aic))/2)/sum(exp(-(dd$aic-min(dd$aic))/2))
# #show(dd[dd$weight>quantile(dd$weight,0.8),])
show(dd[dd$weight>0.01,])
# #show(max(dd$weight))
}





# 
# # 
# data=sdata
# points = SpatialPointsDataFrame(coords=data.frame(data[,c("lonmin","latmin")]),data.frame(data),match.ID=F,proj4string = countries@proj4string)
#  
#  
# # for(i in 1:nrow(bestmodels)){
# gw = gwr.basic(as.character(bestmodels$bestmodel)[i],data=points,bw=floor(bestmodels$bw[i]),adaptive = T)
# # 
# # }
# 
# 
# 
# ###
# ## test : distance matrix
# 
# # data=sdata
# # points = SpatialPointsDataFrame(coords=data.frame(data[,c("lonmin","latmin")]),data.frame(data),match.ID=F,proj4string = countries@proj4string)
# # 
# # lon = sort(unique(data$lonmin));lat=sort(unique(data$latmin))
# # lonsample = lon[seq(from=5,to=length(lon),by=10)];latsample=lat[seq(from=5,to=length(lat),by=10)]
# # calib = matrix(c(c(matrix(rep(lonsample,length(latsample)),nrow = length(latsample),byrow = T)),rep(latsample,length(lonsample))),ncol = 2,byrow = F)
# # 
# # dmat = gw.dist(points@coords,calib,longlat = T)
# # 
# # gw = gwr.basic(meanCloseness~distance+entropy,data=points,bw=271,adaptive = T,dMat = dmat)
# # 
# 



