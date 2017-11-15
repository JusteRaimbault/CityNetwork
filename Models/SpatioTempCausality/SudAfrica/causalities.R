
library(dplyr)
library(igraph)
library(ggplot2)

source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/SpatioTempCausality/SudAfrica'))

resdir = paste0(Sys.getenv('CN_HOME'),'/Results/SpatioTempCausality/SudAfrica/')

#source("networkAnalysis.R")
#source("networkMeasures.R")
source('../functions.R')

load('data/pops.RData')
load('data/distmats.RData')

years = c(1911,1921,1936,1951,1960,1970,1980,1991)
#mean(years[3:length(years)] - years[1:(length(years)-2)])
#23.16667

###########
## Lagged correlations

#
# - varying window size for lagged corrs

# test diffs
popdiff = getDiffs(populations,"pop")

# test accessibility
#year=1991
#pop = populations$pop[populations$year==year];names(pop)<-populations$id[populations$year==year]
#distmat = distmats[[as.character(year)]]
#acc = computeAccess(pop,distmat,1000,mode="weightedboth")

# -> quite quick, ok to recompute to have the deltas

# test deltaacc
#deltaacc = deltaAccessibilities(1000)

#fulldata = data.frame(left_join(x =as.tbl(deltaacc) ,y=as.tbl(popdiff),by=c('id'='id','year'='year')))

#cor.test(x=fulldata$var.x,y=fulldata$var.y)



# application
res=data.frame()
d0s = c(1,10,100,500,1000,2000,3000,4000,5000)
for(mode in c('time','weighteddest','weightedboth')){
  show(mode)
  for(d0 in d0s){
    show(paste0('d0=',d0))
    x= popdiff
    y= deltaAccessibilities(d0,distmats=distmats,years = years,mode=mode)
    for(Tw in 1:7){
      show(paste0('Tw=',Tw))
      currentlaggedcorrs = getLaggedCorrs(x,y,Tw,taumax=3)
      res=rbind(res,cbind(currentlaggedcorrs,mode=mode,d0=d0,Tw=Tw))
    } 
  }
}

#save(res,file='laggedcorrs.RData')
load('laggedcorrs.RData')

for(Tw in 1:7){
 g=ggplot(res[res$Tw==Tw,],aes(x=tau,y=rho,ymin=rhomin,ymax=rhomax,color=d0,group=d0))
 g+geom_point()+geom_line()+geom_errorbar()+facet_grid(mode~span)
 ggsave(paste0(resdir,'laggedCorrs_2_Tw',Tw,'.pdf'),width=30,height=20,units='cm')
}


# detailed figure
Tw=3;mode='time'
g=ggplot(res[res$Tw==Tw&res$mode==mode,],aes(x=tau,y=rho,ymin=rhomin,ymax=rhomax,color=d0,group=d0))
g+geom_point()+geom_line()+geom_errorbar()+facet_wrap(~span)+
  geom_vline(aes(xintercept=0),col='red',linetype=2)+geom_hline(aes(yintercept=0),col='red',linetype=2)+
  xlab(expression(tau))+ylab(expression(rho[tau](Delta*P[i],Delta*T[i])))+scale_color_continuous(name=expression(d[0]))+stdtheme+
  theme(legend.position = c(0.85, 0.25),legend.text=element_text(size=20),legend.title = element_text(size=20))
ggsave(paste0(resdir,'laggedCorrs_time_Tw',Tw,'.png'),width=30,height=20,units='cm')




#######
# significant corrs and levels of correlation

sres = data.frame()
for(d0 in d0s){
  sres=rbind(sres,cbind(d0=rep(d0,7),as.tbl(res[res$d0>=d0,])%>%group_by(Tw)%>%summarise(signcorrs=length(which(rho!=0))/length(which(!is.na(rho))))))
}

g=ggplot(sres,aes(x=Tw,y=signcorrs,color=d0,group=d0))
g+geom_point()+geom_line()
ggsave(paste0(resdir,'significantcorrs.pdf'),width=15,height=10,units='cm')

# -> correlations become less significant with distance -> spatial stationarity effect.
#

sres = data.frame()
for(d0 in d0s){
  sres=rbind(sres,cbind(d0=rep(d0,7),as.tbl(res[res$d0>=d0,])%>%group_by(Tw)%>%summarise(meancorr=mean(rho[rho!=0]),meanabscorr=mean(abs(rho[rho!=0])))))
}

g=ggplot(sres,aes(x=Tw,y=meancorr,color=d0,group=d0))
g+geom_point()+geom_line()
ggsave(paste0(resdir,'meancorrs.pdf'),width=15,height=10,units='cm')

g=ggplot(sres,aes(x=Tw,y=meanabscorr,color=d0,group=d0))
g+geom_point()+geom_line()
ggsave(paste0(resdir,'meanabscorrs.pdf'),width=15,height=10,units='cm')




