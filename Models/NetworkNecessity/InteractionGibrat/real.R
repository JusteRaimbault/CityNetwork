

## Test on real data

library(dplyr)
library(sp)
library(GA)
library(ggplot2)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/NetworkNecessity/InteractionGibrat'))

source('functions.R')

Ncities = 50
d = loadData(Ncities)
cities = d$cities;dates=d$dates;distances=d$distances

## pop matrix
#real_populations = as.matrix(cities[,4:ncol(cities)])

##
#gammaGravity = 1.027532
#decayGravity = 462.5228
#growthRate = 0.0679694
#potentialWeight = 4.420431

#testModel = interactionModel(real_populations,distances,gammaGravity,decayGravity,growthRate,potentialWeight)

#g=ggplot(testModel$df[32:nrow(testModel$df),])
#g+geom_point(aes(x=times,y=populations,colour=cities),shape=2)+
#  geom_point(aes(x=times,y=gibrat_populations,colour=cities),shape=3)+
#  geom_line(aes(x=times,y=real_populations,colour=cities,group=cities))


real_populations = as.matrix(cities[,current_dates+3])
fint =function(params){
  pops=interactionModel(real_populations,distances,params[1],params[2],params[3])$df;
  return(-sum((pops$populations-pops$real_populations)^2))}
optimint = ga(type="real-valued",fitness = fint,min = c(0.01,0,50),max=c(0.1,1e-10,1000),maxiter = 100)#,parallel = 1)






for(t0 in seq(1,21,by=5)){
  current_dates = t0:(t0+10)
  show(current_dates)
  real_populations = as.matrix(cities[,current_dates+3])
  fint =function(params){
    pops=interactionModel(real_populations,distances,params[1],params[2],params[3],params[4])$df;
    return(-sum((pops$populations-pops$real_populations)^2))}
  optimint = ga(type="real-valued",fitness = fint,min = c(0.75,50,0.01,0.1),max=c(1.5,750,0.1,10),maxiter = 100000,parallel = 10)
  
  fgib = function(params){ 
    pops=gibratModel(real_populations,params[1])$df
    return(-sum((pops$populations-pops$real_populations)^2))}
  optimgib = ga(type="real-valued",fitness = fgib,min = c(0.001),max=c(0.2),maxiter = 100000,parallel = 10)
  
  save(optimgib,file=paste0('res/fitTw_gib_t0',t0,'.RData'))
  save(optimint,file=paste0('res/fitTw_int_t0',t0,'.RData'))
}


#############
#############

res=list();allpops=list();plots=list()
t0 = seq(1,21,by=5)
#t0 = seq(1,21,by=10)
cumerror = 0
for(i in 1:length(t0)){
  current_dates = t0[i]:(t0[i]+10)
  load(paste0('res/fitTw_int_t0',t0[i],'.RData'))
  load(paste0('res/fitTw_gib_t0',t0[i],'.RData'))
  res[[i]] = optimint
  #show(res[[i]]@solution)
  real_populations = as.matrix(cities[,current_dates+3])
  pops=interactionModel(real_populations,distances,res[[i]]@solution[1],res[[i]]@solution[2],res[[i]]@solution[3],res[[i]]@solution[4])$df;
  popsgib = gibratModel(real_populations,optimgib@solution[1])
  allpops[[i]]=pops
  pops$gibrat_populations = popsgib$df$populations
  g=ggplot(data.frame(pops,dates=dates[pops$times+t0[i]-1]))
  plots[[i]] = g+geom_point(aes(x=dates,y=log(populations),colour=cities),shape=2)+
    geom_point(aes(x=dates,y=log(gibrat_populations),colour=cities),shape=3)+
    scale_shape_manual(c("interaction","gibrat"))+
    geom_line(aes(x=dates,y=log(real_populations),colour=cities,group=cities))+
    xlab(paste0('Logfit:: int : ',sum((log(pops$real_populations)-log(pops$populations))^2),' ; gib : ',sum((log(pops$real_populations)-log(pops$gibrat_populations))^2)))
  show(paste0('LOG :: int : ',sum((log(pops$real_populations)-log(pops$populations))^2),' ; gib : ',sum((log(pops$real_populations)-log(pops$gibrat_populations))^2)))
  show(paste0('int : ',log(sum((pops$real_populations-pops$populations)^2)),' ; gib : ',log(sum((pops$real_populations-pops$gibrat_populations)^2))))
  cumerror=cumerror+sum((log(pops$real_populations)-log(pops$populations))^2)
}

multiplot(plotlist = plots,cols=3)

g=ggplot(allpops[[5]])
g+geom_point(aes(x=times,y=populations,colour=cities),shape=2)+geom_point(aes(x=times,y=gibrat_populations,colour=cities),shape=3)+geom_line(aes(x=times,y=real_populations,colour=cities,group=cities))



######
# 
# compute cumulated error on independent TS
#  -> use t0 == by 10


