
# functions to compute morphological indicators, to be called from outside
# all supposed to be called on file 'temp_raster'

# libraries
library(raster)
library(bigmemory)

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


# average distance between indivduals
# normalized by max distance = world diagonal

averageDistance <- function(){
  # get densities as vector
  # -> by default numered row by row, transpose to have by column
  N = matrix(data=t(as.matrix(r)),nrow=nrow(m)*ncol(m))
  
  n_patches = length(N)
  n_cols = ncol(m)
  
  # creates distance matrix
  #D = matrix(0,n_patches,n_patches)
  s = 0
  for(i in 1:n_patches){
    if(i %% floor(n_patches / 10) == 0){show(i %/% n_patches)}
    for(j in 1:n_patches){
      s = s + (N[i] * sqrt( ((j-i) %/% n_cols)^2 +  ((j-i) %% n_cols )^2))
    }
  }
  
  D = (D + t(D))
  
  return(matrix(1,1,n_patches) %*% D %*% N)
  
}





