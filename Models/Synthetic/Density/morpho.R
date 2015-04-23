
# functions to compute morphological indicators, to be called from outside
# all supposed to be called on file 'temp_raster'

# libraries
library(raster)
#library(bigmemory)
#setwd('/root/ComplexSystems/CityNetwork/Models/Synthetic//Density')
#setwd(paste0(Sys.getenv("CN_HOME"),'/Models/Synthetic/Density'))
# wd assumed as script dir ? YES
# The environment variable $CN_HOME allows to transparentely run scripts on differents platforms mirroring the project
# (gain of flexibility and time)
# Use cd in source finally

# weights for Moran
spatialWeights <- function (N,P){
  d_hor = (matrix(rep(cumsum(matrix(1,2*N+1,1)),2*P+1),nrow=2*N+1) - N - 1) ^ 2
  d_ver = (matrix(rep(cumsum(matrix(1,2*P+1,1)),2*N+1),ncol=2*P+1,byrow=TRUE) - P - 1) ^ 2
  w = 1 / sqrt(d_hor + d_ver )
  w[w==Inf]=1
  return(w)
}

# load data -> global variable
r_dens = raster("temp_raster_dens.asc")
m = as.matrix(r_dens)
m[is.na(m)] <- 0
r_dens = raster(m)
r_pop = raster("temp_raster_pop.asc")
m = as.matrix(r_pop)
m[is.na(m)] <- 0
r_pop = raster(m)

#moran index 
moranIndex <- function(){
  return(Moran(r_dens,spatialWeights(nrow(r_dens)-1,ncol(r_dens)-1)))
}


# average distance between indivduals
# normalized by max distance = world diagonal

distanceSubMatrix <- function(n_rows,n_cols,raster_cols,row_offset,col_offset){
  di = matrix(rep(cumsum(rep(1,n_rows)),n_cols),nrow=n_rows) + row_offset
  dj = matrix(rep(cumsum(rep(1,n_cols)),n_rows),nrow=n_rows,byrow=TRUE) + col_offset
  return(sqrt((abs(di-dj) %/%  raster_cols)^2 + (abs(di-dj) %% raster_cols)^2))
}

distanceMatrix <- function(N,P){
  d_hor = (matrix(rep(cumsum(matrix(1,2*N+1,1)),2*P+1),nrow=2*N+1) - N - 1) ^ 2
  d_ver = (matrix(rep(cumsum(matrix(1,2*P+1,1)),2*N+1),ncol=2*P+1,byrow=TRUE) - P - 1) ^ 2
  w = sqrt(d_hor + d_ver )
  return(w)
}


# average distance
# still very heavy computationally
# uses focal instead as in Moran Index computation.
#
averageDistance <- function(){
  return(2 * cellStats(focal(r_pop,distanceMatrix(nrow(r_pop)-1,ncol(r_pop)-1),sum,pad=TRUE,padValue=0),sum) / ((nrow(r_pop)*ncol(r_pop))^2 * sqrt(nrow(r_pop)^2 + ncol(r_pop)^2)))

#   # get densities as vector
#   # -> by default numered row by row, transpose to have by column
#   N = matrix(data=t(as.matrix(r)),nrow=nrow(m)*ncol(m))
#   
#   n_patches = length(N)
#   n_cols = ncol(m)
#   
#   # creates distance matrix ?
#   # -> too few memory to do directly big matrices products, whereas too slow to compute iteratively
#   #   :: uses a compromise time/memory, cutting the matrix into smaller matrices.
#   
#   s = 0
#   subMatRows = 200
#   row_offset = 0
#   show((n_patches%/%subMatRows + 1))
#   for(k in 1:(n_patches%/%subMatRows + 1)){
#     # k : submat index
#     show(k)
#     D = distanceSubMatrix(min(subMatRows,n_patches-row_offset-1),n_patches,n_cols,row_offset,0)
#     s = s + (matrix(1,1,min(subMatRows,n_patches-row_offset-1)) %*% (D %*% N))
#     row_offset = row_offset + subMatRows
#     rm(D) # free memory
#   }
#   
#   return(2 * s / (n_patches ^ 2))
}


# distribution entropy --> rough equivalent of integrated local density ?
entropy <- function(){
  m= values(r_dens)*cellStats(r_dens,function(x,...){na.omit(log(x))})
  m[is.na(m)]=0
  return(-1 / log(ncell(r_dens)) * sum(m) )
}


# rank-size slope
# -> linear regression on sorted log series
rankSizeSlope <- function(){
  size = cellStats(r_pop,function(x,...){na.omit(log(x))})
  size = size[size>0] # at least one person
  size=sort(size,decreasing=TRUE)
  rank = log(1:length(size))
  return(lm(size~rank,data.frame(rank,size))$coefficients[2])
}








