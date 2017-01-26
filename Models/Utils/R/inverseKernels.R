
########################
#'
#' Inverse problem Kernel Mixture reconstruction
#'

library(GA)
library(MASS)

###############
#' 
#' Optimize kernels parameters for inverse kernel mixture problem
#' 
#' for all j, f(x_j) = \sum w_c k_c(x_j,\vec{\alpha})
#' to be optimized on \alpha
#'  with 
#'  
#'  Required args :
#'   - histogram : histogram object, or list with slots $density and $mids, corresponding to (x_j) and f(x_j)
#'   - weights : array of weights to be attributed to each kernel, must have \sum weights = 1
#'   - ker : kernel function (first arguments x, other parameters to be optimized) - the function fixedSdGaussian(sigma) provide gaussian kernel
#'   - initialParams : initial values for parameters before optimization (same size as weights) - better be a reasonably thematical guess
#'   
#'   Additional:
#'   - paramsBounds : list with slots $lower and $upper, that are lower and upper bounds for optimization
#'   - costFunction \in {"mse"}
#'   - optimMethod \in {"nlm","ga"} . convex optimization ?
#'   - iter.max = 100 : increase if does not converges well
#'   
#'   Value :
#'     list with slots :
#'       - parameters : optimal parameters
#'       - fittedHist : fitted histogram
#'   
#'   Example :
#'   ------------
#'     #  optmize with fixed width gaussian kernels
#'   
#'     # if q are quantiles of the target distrbution
#'     h = quantilesToHist(q)
#'     # if x is the array whose distrib is targeted,nbreaks arbitrary number of breaks
#'     h=hist(x,nbreaks)
#'     
#'     # weights : let say we have five categories
#'     weights = c(0.4,0.3,0.1,0.1,0.1)
#'     # corresponding initial guesses for means (must be inside [0,max(x)])
#'     # let suppose max(x) = 10
#'     initial = c(1,2,3,6,7)
#'     
#'     # optimize - let take width 1 gaussian
#'     res = inverseKernels(h,weights,fixedSdGaussian(1),initial)
#'     
#'     # let do some stuff with the result : for example plot the hist, the fitted and the obtained gaussian means
#'     # here res$parameters are the means for each category
#'     plot(x = h$mids,y=h$density,type='l')
#'     for(p in 1:length(res$parameters)){abline(v=res$parameters[p],col='red');}
#'     points(x = h$mids,y=res$fittedHist,type='l',col='blue')
#'   
#'   
inverseKernels<-function(histogram,weights,ker,initialParams,paramsBounds = NULL,costFunction="mse",optimMethod="ga",iters.max=100){
  if(is.null(histogram$mids)|is.null(histogram$density)){stop()}
  x = histogram$mids
  y = histogram$density
  y = y / sum(y*diff(c(0,x)))
  
  # kernel
  if(is.null(formals(ker)$x)|length(formals(ker))<2){stop("invalid kernel")}
  # get num of args
  nparams = length(formals(ker))-1

  # cost function
  # by default : abs
  cost=function(x,y){return(sum(abs(x-y)))}
  if(costFunction=="mse"){cost=function(x,y){return(sum((x-y)^2))}}
  
  # function to optimize
  vals=function(params){
    vals = c()
    xx=c(0,x)
    for(j in 1:length(x)){
      k = 0
      for(c in 1:length(weights)){
        k = k + weights[c]*ker(x=x[j],params[((c-1)*nparams+1):(c*nparams)])
      }
      vals=append(vals,k)
    }
    return(vals/sum(vals*diff(c(0,x))))
  }
  
  f = function(params){
    return(cost(y,vals(params)))
  }
  
  # bounds
  bounds = paramsBounds
  if(is.null(paramsBounds)){
     bounds=list()
     bounds$lower = rep(0,length(weights))
     bounds$upper = rep(max(x),length(weights))
  }
  
  
  # optim procedure
  parmin=initialParams
  
  if(optimMethod=="nlm"){
     optim = nlm(f=f,p=initialParams,print.level=2,iterlim = 1000)
     parmin=optim$estimate
  }
  
  if(optimMethod=="optim"){
    mi = optim(par=initialParams,fn = f,method="SANN"#"L-BFGS-B"
               #,lower = paramsBounds$lower,upper = paramsBounds$upper
               ,control = list(trace=2,maxit=50000))
    parmin = mi$par
  }
  
  if(optimMethod=="ga"){
    optim = ga(type="real-valued",
               fitness=function(x){-f(x)},
               min=bounds$lower,
               max=bounds$upper,
               maxiter=iters.max
    )
    parmin=optim@solution
  }
  
  # return parameters, fit
  res=list()
  res$parameters = parmin
  res$fittedHist = vals(parmin)
  
  return(res)
}


#'
#' gaussian kernel of fixed width
fixedSdGaussian<-function(sigma=1){
  return(function(x,mu){1/sqrt(2*pi*sigma)*exp(-(x-mu)^2/(2*sigma^2))})
}

gaussianKernel<-function(){
  return(function(x,pars){mu=pars[1];sigma=pars[2];return(1/sqrt(2*pi*sigma)*exp(-(x-mu)^2/(2*sigma^2)))})
}


#'
#' transform vector of quantiles to an histogram object
#'   ! assuming q > 0
quantilesToHist<-function(q){
  mids=c();density=c()
  a = 1/length(q)
  qq=c(0,q)
  for(i in 1:length(q)){mids = append(mids,(qq[i]+qq[i+1])/2);density=append(density,a/(qq[i+1]-qq[i]))}
  res=list()
  res$mids=mids;res$density=density
  return(res)
}







## tests
# nkers=6
# x=(1:100)/100;
# y=rep(0,length(x))
# mus=c()
# for(i in 1:nkers){
#   mu=runif(1);mus=append(mus,mu)
#   y=y+sapply(x,function(x){fixedSdGaussian(0.1)(x,mu)})
# }
# 
# 
# res = inverseKernels(histogram = list(mids=x,counts=y),
#                      weights = rep(1,nkers),
#                      ker = fixedSdGaussian(0.1),
#                      initialParams = runif(nkers),
#                      paramsBounds=list(lower=rep(0,nkers),upper=rep(1,nkers)))
# mus
# res$parameters
# 
# plot(x,y,type='l')
# for(p in 1:length(res$parameters)){
#   #abline(v=mus[p],col='blue')
#   abline(v=res$parameters[p],col='red');
# }

# GA seems better in all cases



# test with a lognormal plus unif noise
x=rlnorm(100000);x[x>5] = runif(length(which(x>5)))
nkers = 10

res = inverseKernels(histogram =hist(x,breaks=100,plot=FALSE),
                     weights = (1:nkers)/(nkers*(nkers+1)/2),#rep(1,nkers),
                     ker = fixedSdGaussian(0.2),
                     initialParams = runif(nkers),
                     paramsBounds=list(lower=rep(min(x),nkers),upper=rep(max(x),nkers)),
                     iters.max = 200
                     )

hist(x,breaks=100,freq=FALSE)
h=hist(x,breaks=100,freq=FALSE)
for(p in 1:length(res$parameters)){
  #abline(v=mus[p],col='blue')
  abline(v=res$parameters[p],col='red');
}
points(x = h$mids,y=res$fittedHist,type='l',col='blue')


###
# TODO
# test with variable sigma ?



## 
# TODO
# -- test on real data --
#




q= c(800,900,1000,1100,1200,1500,1900,2500,5000,10000)

fit = fitdistr(q,densfun = "log-normal")
y=rlnorm(n=100000,fit$estimate[1],fit$estimate[2])
y=y[y<q[length(q)]];
yy=hist(y,plot=FALSE,breaks = 100)

# weights : let say we have five categories
weights = c(0.4,0.35,0.1,0.1,0.05)
# corresponding initial guesses for means (must be inside [0,max(x)])
initial=rep(0,length(weights))

# optimize - let take width 1 gaussian
res = inverseKernels(yy,weights,fixedSdGaussian(500),initial,iters.max = 400)

# let do some stuff with the result : for example plot the hist, the fitted and the obtained gaussian means
# here res$parameters are the means for each category
plot(x = yy$mids,y=yy$density,type='l')
for(p in 1:dim(res$parameters)[2]){show(res$parameters[1,p]);abline(v=res$parameters[1,p],col='red');}
points(x = yy$mids,y=res$fittedHist,type='l',col='blue')






