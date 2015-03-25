
# Morphological analysis of population densities

# using package spatstat
library(spatstat)
#beginner
#vignette('getstart')

#needs raster also
library(raster)
library(rgdal)

# create data structures
# load raw raster
raw <- raster("/Users/Juste/Documents/ComplexSystems/CityNetwork/Data/PopulationDensity/bassin_parisien.tif")
m = as.matrix(raw)
m[is.na(m)] <- 0

hist(c(m),breaks=100)

#composition of raster ?
threshold = 50
sum(m>threshold)/length(m)

binmat<- m>threshold
sum(binmat)/length(m)

w <- as.owin(im(as.matrix(binmat)))

o <- opening(w,10)
