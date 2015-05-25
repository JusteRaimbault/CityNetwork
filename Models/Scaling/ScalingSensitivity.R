
########################
## Study of scaling sensitivity to city definition
## (see Cottineau & al.)
########################
#
# numerical study and confirmation of analytical results
#

library(kernlab)
library(plot3D)

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
spatializedExpMixtureDensity <- function(gridSize,N,rmin,rmax,Pmax,alpha,tolThreshold,kernel_type){
  
  # patches of the grid are 1 unit size (in r_min/max units)
  grid = matrix(0,gridSize,gridSize)
  
  # matrix of coordinates
  coords = matrix(c(c(matrix(rep(1:gridSize,gridSize),nrow=gridSize)),c(matrix(rep(1:gridSize,gridSize),nrow=gridSize,byrow=TRUE))),nrow=gridSize^2)
  
  # first draw param distribs ? not needed
  # for exp distribs, P_i = 2pi*d_i*r_i^2
  #  -> take P from deterministic distrib ; draw r.
  
  for(i in 1:N){
    show(i)
    pop_i = Pmax*i^{-alpha}
    r_i = runif(1,min=rmin,max=rmax)
    d_i = pop_i / (2*pi*(r_i^2))
    
    # find origin of that kernel
    #  -> one of points such that : d(bord) > rcut and \forall \vec{x}\in D(rcut),d(\vec{x})<tolThr.
    pot = which(!pseudoClosing(grid>tolThreshold,r_i),arr.ind=TRUE)
    show(length(pot))
    if(length(pot)==0){
      # Take a point with minimal density ?
      pot = which(grid==min(grid),arr.ind=TRUE)
    }
    
    row = sample(nrow(pot),1)
    center = matrix(pot[row,],nrow=1)
    
    # add kernel : use kernlab laplace kernel or other
    if(kernel_type=="poisson"){ker=laplacedot(sigma=1/r_i)}
    if(kernel_type=="gaussian"){ker=rbfdot(sigma=1/r_i)}
    #if(kernel_type="quadratic"){ker=} # is quad kernel available ?
    
    grid = grid + (d_i * matrix(kernelMatrix(kernel=laplacedot(sigma=1/r_i),x=coords,y=center),nrow=gridSize))
    
  }
  
  return(grid)
}

pseudoClosing <- function(mat,rcut){
  res=matrix(mat,nrow=nrow(mat))
  for(i in 1:nrow(mat)){
    for(j in 1:ncol(mat)){
      if(i>rcut&&i<nrow(mat)-rcut+1&&j>rcut&&j<ncol(mat)-rcut+1){
        # dirty that way - should be quicker with convol.
        # furthermore Manhattan distance, not best solution for distribs symmetric by rotation.
        if(sum(mat[(i-rcut):(i+rcut),(j-rcut):(j+rcut)])>=1){res[i,j]=1}
      }else{res[i,j]=1}
    }
  }
  return(res)
}



# test the function
#test = spatializedExpMixtureDensity(400,20,10,10,200,0.5,0.01)
#persp3D(z=test)
# -> not disgusting


# test the scaling
#
# for counter proportionnal to density.

# cut at threshold, get sizes of each cluster.

# use connexAreas function of morphoAnalysis

# function giving slope as a function of theta
linFit <- function(d,theta){
  c = connexAreas(d>theta)
  pops = c()
  for(i in 1:length(c)){pops=append(pops,sum(d[c[[i]]]))}
  x=log(1:length(pops))
  y=log(sort(pops,decreasing=TRUE))
  return(lm(y~x,data.frame(x,y)))
}


# Empirical scaling exponent log(A_i) = K - alpha log(P_i)
empScalExp <- function(theta,lambda,beta,d){
  c = connexAreas(d>theta)
  pops = c();amens = c()
  for(i in 1:length(c)){
    pops=append(pops,sum(d[c[[i]]]))
    amens=append(amens,sum(lambda*d[c[[i]]]^beta))
  }
  x=log(pops)
  y=log(amens)
  fit = lm(y~x,data.frame(x,y))
  return(fit$coefficients[2])
}


#
#slope(test,0.02)
#persp3D(z=d)

#d=spatializedExpMixtureDensity(200,15,5,5,200,0.7,0.001)

#thetas=seq(from=0.01,to=0.2,by=0.005)
# be careful in thresholds, not good connex areas otherwise
# thetas given in proportion
#slopes=c();rsquared=c()
#for(theta in thetas){
#  l=linFit(d,theta*max(d))
#  slopes=append(slopes,l$coefficients[2])
#  rsquared=append(rsquared,summary(l)$adj.r.squared)
#}

#plot(thetas,-slopes)
#plot(thetas,rsquared)

# slope of slopes ?
#lm(-slopes~thetas,data.frame(thetas,slopes))$coefficients[2]


