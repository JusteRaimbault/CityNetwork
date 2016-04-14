
######
#  generation of synthetic dataset for interaction Gibrat estimation

library(sp)
library(rgeos)

ranksize = 0.8
Pmax = 50000
Ncities = 50

cities = data.frame(x=runif(Ncities,0,500),y=runif(Ncities,0,500),population=Pmax/(1:Ncities)^ranksize)
distances = spDists(as.matrix(cities[,1:2]))


##  generate synthetic time series

growthRate = 0.05
gammaGravity = 1.3
decayGravity = 100
potentialWeight = 1
times=10

potentials <-function(populations){
  ptot = sum(populations)
  return(diag((populations/ptot)^gammaGravity)%*%exp(-distances / decayGravity)%*%diag((populations/ptot)^gammaGravity))
}

populations = matrix(0,Ncities,times)
populations_gibrat = matrix(0,Ncities,times)
populations[,1] = cities$population
populations_gibrat[,1] = cities$population
pflat=cities$population;pgflat=cities$population;tflat=rep(1,Ncities);cflat=1:Ncities
for(t in 2:times){
  pot = potentials(populations[,t-1])
  populations[,t] = populations[,t-1]*(1 + growthRate + pot%*%matrix(rep(1,nrow(pot)),nrow=nrow(pot))/potentialWeight)
  populations_gibrat[,t] = populations_gibrat[,t-1]*(1 + growthRate)
  pflat=append(pflat, populations[,t]);pgflat=append(pgflat, populations_gibrat[,t]);tflat=append(tflat,rep(t,Ncities));cflat=append(cflat,1:Ncities)
}


df = data.frame(pflat,pgflat,tflat,cflat)
g=ggplot(df)
g+geom_point(aes(x=tflat,y=pflat,colour=cflat),shape=1)+geom_point(aes(x=tflat,y=pgflat,colour=cflat),shape=3)




