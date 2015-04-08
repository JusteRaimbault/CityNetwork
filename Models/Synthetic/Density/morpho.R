
# functions to compute morphological indicators, to be called from outside
# all supposed to be called on file 'temp_raster'

# libraries
library(raster)


# weights for Moran
spatialWeights <- function (N,P){
  d_hor = (matrix(rep(cumsum(matrix(1,2*N+1,1)),2*P+1),nrow=2*N+1) - N - 1) ^ 2
  d_ver = (matrix(rep(cumsum(matrix(1,2*P+1,1)),2*N+1),ncol=2*P+1,byrow=TRUE) - P - 1) ^ 2
  w = 1 / sqrt(d_hor + d_ver )
  w[w==Inf]=1
  return(w)
}

# load data -> global variable
r = raster("temp_raster.asc")
m = as.matrix(r)
m[is.na(m)] <- 0
r = raster(m)

#moran index 
moranIndex <- function(){
  return(Moran(r,spatialWeights(floor(nrow(m)/2),floor(ncol(m)/2))))
}



