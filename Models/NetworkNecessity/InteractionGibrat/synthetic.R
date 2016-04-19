

library(sp)
library(rgeos)
library(ggplot2)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/NetworkNecessity/InteractionGibrat'))

source('functions.R')

######
#  generation of synthetic dataset for interaction Gibrat estimation



ranksize = 0.8
Pmax = 50000
Ncities = 50

cities = data.frame(x=runif(Ncities,0,500),y=runif(Ncities,0,500),population=Pmax/(1:Ncities)^ranksize)
distances = spDists(as.matrix(cities[,1:2]))

######
##  generate synthetic time series

gammaGravity = 1.4
decayGravity = 100
growthRate = 0.03
potentialWeight = 1
times=50

synth_populations = matrix(0,Ncities,times);synth_populations[,1]=cities$population
synth_populations = interactionModel(synth_populations,distances,gammaGravity,decayGravity,growthRate,potentialWeight)$populations

#g=ggplot(synth_populations$df)
#g+geom_point(aes(x=times,y=populations,colour=cities),shape=2)+geom_point(aes(x=times,y=gibrat_populations,colour=cities),shape=3)

#####
## try to fit different models

nlm(f=function(params){
      pops=interactionModel(synth_populations,distances,params[1],params[2],params[3],params[4])$df;
      if(params[3]<0) return(sum(pops$populations^4)) else return(sum((pops$populations-pops$real_populations)^2))},
    p=c(1.2,200,0.01,0.5),steptol = 1e-40,iterlim = 10000,print.level=2
  )

f =function(params){
  pops=interactionModel(synth_populations,distances,params[1],params[2],params[3],params[4])$df;
  return(-sum((pops$populations-pops$real_populations)^2))}

optim = ga(type="real-valued",fitness = f,min = c(0.75,25,0.01,0.5),max=c(2,300,0.08,5),maxiter = 1000)




