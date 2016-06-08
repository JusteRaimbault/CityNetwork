

## Test on real data

library(dplyr)
library(sp)
library(GA)
library(ggplot2)
library(Matrix)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/NetworkNecessity/InteractionGibrat'))

source('functions.R')

Ncities = 50
d = loadData(Ncities)
cities = d$cities;dates=d$dates;distances=d$distances

alpha0=3;n0=3
load(paste0('data/distMat_Ncities',Ncities,'_alpha0',alpha0,'_n0',n0,'.RData'))
dists[dists==0]=1e8

## pop matrix
real_populations = as.matrix(cities[,4:ncol(cities)])
colnames(real_populations)<-dates

# export time periods to fit
#periods = list("1831-1881"=1:11,"1856-1911"=6:17,"1921-1936"=18:21,"1946-1999"=23:31)
periods = list("1831-1851"=1:5,"1841-1861"=3:7,"1851-1872"=5:9,"1861-1881"=7:11,"1872-1891"=9:13,
               "1881-1901"=11:15,"1891-1911"=13:17,"1921-1936"=18:21,"1946-1968"=c(23,24,26,27),"1962-1982"=26:29,
               "1975-1990"=28:31)
#for(i in 1:length(periods)){write.table(real_populations[,periods[[i]]],file=paste0('data/popshort/pop50_',names(periods)[i],'.csv'),col.names = FALSE,row.names = FALSE,sep=',')}
#write.table(distances,file='data/dist50.csv',col.names = FALSE,row.names = FALSE,sep=',')
#write.table(data.frame(as.matrix(dists)),file=paste0('data/distMat_Ncities',Ncities,'_alpha0',alpha0,'_n0',n0,'.csv'),col.names = FALSE,row.names = FALSE,sep=',')
#

##
#gammaGravity = 1.027532
#decayGravity = 462.5228
#growthRate = 0.0679694
#potentialWeight = 4.420431

#0.06, 0.002, 0.8, 1000, 0.0, 0.001, 0.8, 100
#testModel = interactionModel(real_populations,distances,gammaGravity,decayGravity,growthRate,potentialWeight)
lmse=c()
for(feedbackDecay in seq(from=10,to=200,by=10)){
pops=networkFeedbackModel(real_populations,distances,dists,
                          gammaGravity=1,decayGravity=1000,growthRate=0.06,
                          potentialWeight=0.0,betaFeedback=0.2,feedbackDecay=feedbackDecay);
show(as.character(sum((log(pops$df$populations)-log(pops$df$real_populations))^2)))
show(as.character(log(sum((pops$df$populations-pops$df$real_populations)^2))))
lmse=append(lmse,log(sum((pops$df$populations-pops$df$real_populations)^2)))
}
plot(seq(from=10,to=200,by=10),lmse)

# 
errs=data.frame()
for(feedbackWeight in seq(from=0.2,to=0.4,by=0.025)){
for(feedbackDecay in seq(from=10,to=200,by=10)){
#for(gravityWeight in seq(from=0.001,to=0.006,by=0.0005)){
#  for(gravityDecay in seq(from=100,to=1500,by=100)){
 #for(gammaGravity in seq(from=0.4,to=1.4,by=0.2)){
  gammaGravity=1.0
  pops=networkFeedbackModel(real_populations,distances,dists,
          gammaGravity=gammaGravity,decayGravity=1000.0,growthRate=0.06,
          potentialWeight=0.0,betaFeedback=feedbackWeight,feedbackDecay=feedbackDecay)$df;
  show(paste0('decay : ',feedbackDecay,'km ; ',sum((pops$populations-pops$real_populations)^2)))
   errs=rbind(errs,c(gammaGravity,feedbackWeight,feedbackDecay,mselog=sum((log(pops$populations)-log(pops$real_populations))^2),logmse=log(sum((pops$populations-pops$real_populations)^2))))
  #errs=rbind(errs,c(gravityWeight,gravityDecay,gammaGravity,sum((log(pops$populations)-log(pops$real_populations))^2)))
  }
  }
#}

names(errs)<-c("gammaGravity","betaFeedback","feedbackDecay","mselog","logmse")
#names(errs)<-c("gravityWeight","gravityDecay","gammaGravity","mse")
g=ggplot(errs)
g+geom_line(aes(x=feedbackDecay,y=logmse,colour=betaFeedback,group=betaFeedback))+facet_wrap(~gammaGravity,scales="free")

#g=ggplot(testModel$df[32:nrow(testModel$df),])

# g=ggplot(pops)
# g+geom_point(aes(x=times,y=log(populations),colour=cities),shape=2)+
# #  geom_point(aes(x=times,y=gibrat_populations,colour=cities),shape=3)+
#   geom_line(aes(x=times,y=log(real_populations),colour=cities,group=cities))

# 
# real_populations = as.matrix(cities[,current_dates+3])
# fint =function(params){
#   pops=interactionModel(real_populations,distances,params[1],params[2],params[3])$df;
#   return(-sum((pops$populations-pops$real_populations)^2))}
# optimint = ga(type="real-valued",fitness = fint,min = c(0.01,0,50),max=c(0.1,1e-10,1000),maxiter = 100)#,parallel = 1)
# 




for(t0 in seq(1,21,by=5)){
  current_dates = t0:(t0+10)
  show(current_dates)
  real_populations = as.matrix(cities[,current_dates+3])
  
  fnet =function(params){
      pops=networkFeedbackModel(real_populations,distances,dists,params[1],params[2],params[3],params[4],params[5],params[6])$df;
      return(-sum((log(pops$populations)-log(pops$real_populations))^2))}
  optimnet = ga(type="real-valued",fitness = fnet,min = c(0.5,50,0.01,0.0,0.0,0.0),max=c(2.0,1500,0.1,0.1,1,300),maxiter = 50000,parallel = 10)
   
  
  # fint =function(params){
  #   pops=interactionModel(real_populations,distances,params[1],params[2],params[3],params[4])$df;
  #   return(-sum((pops$populations-pops$real_populations)^2))}
  # optimint = ga(type="real-valued",fitness = fint,min = c(0.5,50,0.01,0.1),max=c(2.0,1500,0.1,100),maxiter = 200000,parallel = 20)
  # 
  # fgib = function(params){ 
  #   pops=gibratModel(real_populations,params[1])$df
  #   return(-sum((pops$populations-pops$real_populations)^2))}
  # optimgib = ga(type="real-valued",fitness = fgib,min = c(0.001),max=c(0.2),maxiter = 200000,parallel = 20)
  # 
  #save(optimgib,file=paste0('res/fitTw_gib_t0',t0,'.RData'))
  
  save(optimnet,file=paste0('res/fitTw_net_t0',t0,'.RData'))
}


#############
#############

# res=list();allpops=list();plots=list()
# t0 = seq(1,21,by=5)
# #t0 = seq(1,21,by=10)
# cumerror = 0
# for(i in 1:length(t0)){
#   current_dates = t0[i]:(t0[i]+10)
#   load(paste0('res/fitTw_int_t0',t0[i],'.RData'))
#   load(paste0('res/fitTw_gib_t0',t0[i],'.RData'))
#   res[[i]] = optimint
#   #show(res[[i]]@solution)
#   real_populations = as.matrix(cities[,current_dates+3])
#   pops=interactionModel(real_populations,distances,res[[i]]@solution[1],res[[i]]@solution[2],res[[i]]@solution[3],res[[i]]@solution[4])$df;
#   popsgib = gibratModel(real_populations,optimgib@solution[1])
#   allpops[[i]]=pops
#   pops$gibrat_populations = popsgib$df$populations
#   g=ggplot(data.frame(pops,dates=dates[pops$times+t0[i]-1]))
#   plots[[i]] = g+geom_point(aes(x=dates,y=log(populations),colour=cities),shape=2)+
#     geom_point(aes(x=dates,y=log(gibrat_populations),colour=cities),shape=3)+
#     scale_shape_manual(c("interaction","gibrat"))+
#     geom_line(aes(x=dates,y=log(real_populations),colour=cities,group=cities))+
#     xlab(paste0('Logfit:: int : ',sum((log(pops$real_populations)-log(pops$populations))^2),' ; gib : ',sum((log(pops$real_populations)-log(pops$gibrat_populations))^2)))
#   show(paste0('LOG :: int : ',sum((log(pops$real_populations)-log(pops$populations))^2),' ; gib : ',sum((log(pops$real_populations)-log(pops$gibrat_populations))^2)))
#   show(paste0('int : ',log(sum((pops$real_populations-pops$populations)^2)),' ; gib : ',log(sum((pops$real_populations-pops$gibrat_populations)^2))))
#   cumerror=cumerror+sum((log(pops$real_populations)-log(pops$populations))^2)
# }
# 
# multiplot(plotlist = plots,cols=3)
# 
# g=ggplot(allpops[[5]])
# g+geom_point(aes(x=times,y=populations,colour=cities),shape=2)+geom_point(aes(x=times,y=gibrat_populations,colour=cities),shape=3)+geom_line(aes(x=times,y=real_populations,colour=cities,group=cities))
# 
# 

######
# 
# compute cumulated error on independent TS
#  -> use t0 == by 10


