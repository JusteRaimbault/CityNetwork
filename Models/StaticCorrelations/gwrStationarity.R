


# gwr stationarity test

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



###############



load('res/gwr_allpoints.RData')

d = as.tbl(data.frame(bw=sapply(resgwr,function(l){l$bw}),
                      meandist=sapply(resgwr,function(l){l$meandist}),
                      aic=sapply(resgwr,function(l){l$aic}),
                      R2=sapply(resgwr,function(l){l$r2}),
                      model=sapply(resgwr,function(l){l$model}),
                      indic=sapply(resgwr,function(l){l$indic})
))


bestmodels = d%>%group_by(indic)%>%summarise(bestmodel=model[which(aic==min(aic))],dist=meandist[which(aic==min(aic))],bw=bw[which(aic==min(aic))],R2=R2[which(aic==min(aic))])

library(doParallel)
cl <- makeCluster(8,outfile='loggwr')
registerDoParallel(cl)

resgwrstat <- foreach(i=1:nrow(bestmodels)) %dopar% {
  library(GWmodel);library(sp);set.seed(i)
  currentmodel = bestmodels$bestmodel[i]
  gw = gwr.montecarlo(currentmodel,data=points,bw=bestmodels$bw[i],dMat = dmat,adaptive = T)
  return(gw)
}

save(resgwrstat,file='res/gwr_stationarity,RData')




