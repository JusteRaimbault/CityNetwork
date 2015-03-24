
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
binmat<- (as.matrix(na.omit(as.matrix(raw))))>10000
sum(binmat)

w <- as.owin(im(as.matrix(raw)))


opening(w,10)
