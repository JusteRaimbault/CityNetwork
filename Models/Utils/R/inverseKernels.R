
########################
#'
#' Inverse problem Kernel Mixture reconstruction
#'

#'
#' for all j,
#' f(x_j) = \sum w_c k_c(x_j,\vec{\alpha})
#' to be optimized on \alpha
#'  with 
#'  
#'   - histogram : histogram object, or list with slots $counts and $mids
#'   - optimMethod \in {"nlm","ga"} . convex optimization ?
inverseKernels<-function(histogram,weights,ker,initialParams,paramsBounds,costFunction="mse",optimMethod="ga"){
  if(is.null(histogram$mids)|is.null(histogram$counts)){stop()}
  x = histogram$mids
  y = histogram$counts
  
  # kernel
  if(is.null(formals(ker)$x)|length(formals(ker))<2){stop("invalid kernel")}
  # get num of args
  nparams = length(formals(ker))-1

  # cost function
  # by default : abs
  cost=function(x,y){return(sum(abs(x-y)))}
  if(costFunction=="mse"){cost=function(x,y){return(sum((x-y)^2))}}
  
  # function to optimize
  f = function(params){
    vals = c()
    for(j in 1:length(x)){
      k = 0
      for(c in 1:length(weights)){
        k = k + weights[c]*ker(x=x[j],params[((c-1)*nparams+1):(c*nparams)])
      }
      vals=append(vals,k)
    }
    return(cost(y,vals))
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
               min=paramsBounds$lower,
               max=paramsBounds$upper,
               maxiter=100
    )
    parmin=optim@solution
  }
  
  # return parameters, fit
  res=list()
  res$parameters = parmin
  
  return(res)
}


#'
#' gaussian kernel of fixed width
fixedSdGaussian<-function(sigma=1){
  return(function(x,mu){exp(-(x-mu)^2/(2*sigma^2))})
}





## tests
nkers=8
x=(1:100)/100;
y=rep(0,length(x))
mus=c()
for(i in 1:nkers){
  mu=runif(1);mus=append(mus,mu)
  y=y+sapply(x,function(x){fixedSdGaussian(0.1)(x,mu)})
}

res = inverseKernels(histogram = list(mids=x,counts=y),
                     weights = rep(1,nkers),
                     ker = fixedSdGaussian(0.1),
                     initialParams = runif(nkers),
                     paramsBounds=list(lower=rep(0,nkers),upper=rep(1,nkers)))
mus
res$parameters

plot(x,y,type='l')
for(p in 1:length(res$parameters)){
  #abline(v=mus[p],col='blue')
  abline(v=res$parameters[p],col='red');
}

# GA seems better in all cases



