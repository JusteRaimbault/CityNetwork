
setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))

source('functions.R')
source('mapFunctions.R')

library(Matrix)

countrycode="FR"

areasize=200;offset=100;factor=0.5
res1 = loadIndicatorData(paste0("res/europecoupled_areasize",areasize,"_offset",offset,"_factor",factor,"_temp.RData"))

areasize=100;offset=50;factor=0.5
res2 = loadIndicatorData("res/res/europe_areasize100_offset50_factor0.5_20160824.csv")


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

dmat = spDists(datapoints1@coords,datapoints2@coords,longlat = T)

d0 = 0.1

M = exp(-dmat/d0)
W = Diagonal(x=1/rowSums(M))%*%Matrix(M)

# use the weight matrix to compute smoothed field

# correlations make sense on intensive indices only

X = matrix(data=sdata2$moran,nrow=ncol(W));X[is.na(X)]=0
Y = W%*%X
cor(sdata1$moran,Y[,1])

map(c(3),'moran_corresp.png',20,18,c(1,1),sdata=data.frame(lonmin=sdata1$lonmin,latmin=sdata1$latmin,moran=((sdata1$moran+Y[,1])/2)^10))


X = matrix(data=sdata2$slope,nrow=ncol(W));X[is.na(X)]=0
Y = W%*%X
cor(sdata1$rankSizeAlpha,Y[,1])

X = matrix(data=sdata2$entropy,nrow=ncol(W));X[is.na(X)]=0
Y = W%*%X
cor(sdata1$entropy,Y[,1])

X = matrix(data=sdata2$distance,nrow=ncol(W));X[is.na(X)]=0
Y = W%*%X
cor(sdata1$averageDistance,Y[,1])




