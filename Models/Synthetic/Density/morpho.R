
# functions to compute morphological indicators, to be called from outside
# all supposed to be called on file 'temp_raster'

# weights for Moran
spatialWeights <- function (N){
  d = (matrix(rep(cumsum(matrix(1,2*N+1,1)),2*N+1),nrow=2*N+1) - N - 1) ^ 2
  w = 1 / sqrt(d + t(d))
  w[w==Inf]=1
  return(w)
}

# load data
r = raster("temp_raster.asc")
m = as.matrix(r)
m[is.na(m)] <- 0
r = raster(m)

#moran index 
moranIndex <- function(){
  return(Moran(r,spatialWeights(min(nrow(m),ncol(m)))))
}