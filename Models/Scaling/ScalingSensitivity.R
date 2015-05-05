
########################
## Study of scaling sensitivity to city definition
## (see Cottineau & al.)
########################
#
# numerical study and confirmation of analytical results
#


# Generate a random density distribution
#   following a scaling law with params alpha, dmax
#   with additional radius constraint [rmin,rmax]
#   with superposition tolerance interThreshold
#   , on a square spatial grid of size gridSize, by a mixture of
#   N exponential kernels (endog. params d_i,r_i)
#
#  rq : unspatialized function more simple ? could only return params of each kernel, not really interesting.
#
#  todo : stricy power law here ; add real values - or synthetic noise
#
spatializedExpMixtureDensity <- function(gridSize,N,rmin,rmax,dmax,alpha,interThreshold){
  
  # patches of the grid are 1 unit size (in r_min/max units)
  grid = matrix(0,gridSize,gridSize)
  
  # first draw param distribs
    
}






