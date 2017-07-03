
# test random forests

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R'))
source('FunctionsRFclustering.R')

synthClusters <- function(n,k=2,p=2,alpha=0.1){
  res = data.frame(matrix(data = rep(0,n*p),ncol = p,nrow = n))
  clusters = sample.int(k,size=n,replace = T)
  for(pp in 1:p){
    centers = runif(n = k,min = 0,max=1)
    res[,pp]=jitter(centers[clusters],amount=alpha)
  }
  return(res)
}

dat = synthClusters(1000,k=3,alpha=0.2)

no.trees=1000
no.forests=100
distRF = RFdist(dat, mtry1=1, no.trees, no.forests, addcl1=T,addcl2=F,imp=T, oob.prox1=T) 

# pam clustering using the distance matrix
no.clusters=2
labelRF = pamNew(distRF$cl1,no.clusters) 

# euclidian for comparison
distmat = dist(dat)
labelEuclid = pamNew(distmat,4) 

plot(dat,col=labelEuclid)
plot(dat,col=labelRF)
