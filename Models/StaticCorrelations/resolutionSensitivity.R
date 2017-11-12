
setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))

source('functions.R')
source('mapFunctions.R')
source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

library(Matrix)

countrycode="FR"

areasize=200;offset=100;factor=0.5
res1 = loadIndicatorData(paste0("res/europecoupled_areasize",areasize,"_offset",offset,"_factor",factor,"_temp.RData"))

areasize=100;offset=50;factor=0.5
#res2 = loadIndicatorData("res/res/europe_areasize100_offset50_factor0.5_20160824.csv")
res2 = loadIndicatorData(paste0("res/europecoupled_areasize",areasize,"_offset",offset,"_factor",factor,"_temp.RData"))

#areasize=60;offset=30;factor=0.5
#res2 = loadIndicatorData(paste0("res/europecoupled_areasize",areasize,"_offset",offset,"_factor",factor,"_temp.RData"))



######
#unique(sort(sdata1$latmin))
#unique(sort(sdata2$latmin))

countries = readOGR('gis','countries')
country = countries[countries$CNTR_ID==countrycode,]
datapoints = SpatialPoints(data.frame(res1[,c("lonmin","latmin")]),proj4string = countries@proj4string)
selectedpoints = gContains(country,datapoints,byid = TRUE);sdata1 = res1[selectedpoints,]
datapoints1=datapoints[selectedpoints,]
datapoints = SpatialPoints(data.frame(res2[,c("lonmin","latmin")]),proj4string = countries@proj4string)
selectedpoints = gContains(country,datapoints,byid = TRUE);sdata2 = res2[selectedpoints,]
datapoints2=datapoints[selectedpoints,]

#plot(datapoints1)
#plot(datapoints2,pch=".",col='red',add=T)

dmat = spDists(datapoints1@coords,datapoints2@coords,longlat = T)

corrs=c();indics=c();d0s=c()
for(d0 in seq(1,25,2)){
  show(d0)
  M = exp(-dmat/d0)
  W = Diagonal(x=1/rowSums(M))%*%Matrix(M)
  for(indic in names(sdata1)){
# use the weight matrix to compute smoothed field
# correlations make sense on intensive indices only
X = matrix(data=sdata2[,indic],nrow=ncol(W));X[is.na(X)]=0
Y = W%*%X
corrs=append(corrs,cor(sdata1[,indic],Y[,1]))
d0s=append(d0s,d0);indics=append(indics,indic)

#map(c(3),'moran_corresp.png',20,18,c(1,1),sdata=data.frame(lonmin=sdata1$lonmin,latmin=sdata1$latmin,moran=((sdata1$moran+Y[,1])/2)^10))
}
}

g=ggplot(data.frame(corr=corrs,d0=d0s,indic=indics),aes(x=d0,y=corr,color=indic,group=indic))
g+geom_point()+geom_line()+stdtheme



