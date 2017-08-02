
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
nbootstrap = 10
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
cl <- makeCluster(60,outfile='loggwr')
registerDoParallel(cl)

resgwr <- foreach(i=1:length(models)) %dopar% {
  library(GWmodel);library(sp);set.seed(i)
  currentmodel = models[i]
  show(paste0('Model ',i,' : ',currentmodel))
  data=sdata[sample.int(nrow(sdata),size=3000,replace = F),]
  points = SpatialPointsDataFrame(coords=data.frame(data[,c("lonmin","latmin")]),data.frame(data),match.ID=F,proj4string = countries@proj4string)
  bw = bw.gwr(currentmodel,data=points,approach = 'AIC',adaptive = T)
  gw = gwr.basic(currentmodel,data=points,bw=bw,adaptive = T)
  d=spDists(points,longlat = T)
  meandist = mean(apply(d,1,function(r){mean(sort(r[r>0])[1:bw])}))
  return(list(bw=bw,meandist=meandist,aic = gw$GW.diagnostic$AICc,model=model,indic=strsplit(model,split='~')[[1]][1]))
}

save(resgwr,file='res/gwr.RData')





