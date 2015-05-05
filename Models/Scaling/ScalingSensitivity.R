
########################
## Study of scaling sensitivity to city definition
## (see Cottineau & al.)
########################
#
# numerical study and confirmation of analytical results
#


# Generate a random density distribution
#   following a scaling law with params alpha>0, Pmax (P_i = Pmax*i^{-\alpha})
#   with additional radius constraint [rmin,rmax]
#   with superposition tolerance tolThreshold
#   , on a square spatial grid of size gridSize, by a mixture of
#   N exponential kernels (endog. params d_i,r_i)
#
#  rq : unspatialized function more simple ? could only return params of each kernel, not really interesting.
#
#  todo : stricy power law here ; add real values - or synthetic noise
#
spatializedExpMixtureDensity <- function(gridSize,N,rmin,rmax,Pmax,alpha,tolThreshold){
  
  # patches of the grid are 1 unit size (in r_min/max units)
  grid = matrix(0,gridSize,gridSize)
  
  # first draw param distribs ? not needed
  # for exp distribs, P_i = 2pi*d_i*r_i^2
  #  -> take P from deterministic distrib ; draw r.
  
  for(i in 1:N){
    pop_i = Pmax*i^{-alpha}
    r_i = runif(1,min=rmin,max=rmax)
    d_i = pop_i / (2*pi*(r_i^2))
    
    # find origin of that kernel
    #  -> one of points such that : d(bord) > rcut and \forall \vec{x}\in D(rcut),d(\vec{x})<tolThr.
    
    
    
    
  }
  
  return(grid)
}

pseudoClosing <- function(mat,rcut){
  res=matrix(mat,nrow=nrow(mat))
  for(i in 1:nrow(mat)){
    for(j in 1:ncol(mat)){
      if(i>rcut&&i<nrow(mat)-rcut+1&&j>rcut&&j<ncol(mat)-rcut+1){
        # dirty that way - should be quicker with convol.
        if(sum(mat[i-rcut+1:i,j-rcut+1:j])>=1){res[i,j]=1}
      }else{res[i,j]=1}
    }
  }
  return(res)
}





