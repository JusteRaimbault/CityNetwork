

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/SpatioTempCausality/France'))

library(dplyr)
library(ggplot2)

source('../functions.R')
source(paste0(Sys.getenv('CN_HOME'),'/Models/NetworkNecessity/InteractionGibrat/functions.R'))
source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))


resdir = paste0(Sys.getenv('CN_HOME'),'/Results/SpatioTempCausality/France/')
dir.create(resdir)

#Ncities = 50
Ncities = 300

load(paste0('data/distmats_cities',Ncities,'.RData'))

citydata = data.frame(loadData(Ncities)$cities)
rownames(citydata)<-citydata$NCCU

years = c(1831,1836,1841,1846,1851,1856,1861,1866,1872,1876,1881,
          1886,1891,1896,1901,1906,1911,1921,1926,1931,1936,
          1946,1954,1955,1962,1968,1975,1982,1990,1999)



#####
# Temporal correlations


pops=c();ids=c();cyears=c()
for(year in years){
  pops=append(pops,citydata[citydata$NCCU,paste0("P",year)]);ids=append(ids,citydata$NCCU);cyears=append(cyears,rep(year,nrow(citydata)))
}
populations = data.frame(id=ids,pop=pops,year=cyears)

popdiff=getDiffs(populations,"pop")

#d0 = 100;mode='time';Tw=1
#x= popdiff;y= deltaAccessibilities(d0,distmats=distmats,years=years,mode=mode)
#getLaggedCorrs(x,y,Tw,taumax=0)

res=data.frame()
d0s = c(1,10,100,500,1000,2000,4000)
for(mode in c('time')){#,'weighteddest','weightedboth')){
  show(mode)
  for(d0 in d0s){
    show(paste0('d0=',d0))
    x= popdiff
    y= deltaAccessibilities(d0,distmats=distmats,years=years,mode=mode)
    for(Tw in 1:10){
      show(paste0('Tw=',Tw))
      currentlaggedcorrs = getLaggedCorrs(x,y,Tw,taumax=3)
      res=rbind(res,cbind(currentlaggedcorrs,mode=mode,d0=d0,Tw=Tw))
    } 
  }
}

mode='time'
for(Tw in 1:10){
  g=ggplot(res[res$Tw==Tw&res$mode==mode,],aes(x=tau,y=rho,ymin=rhomin,ymax=rhomax,color=d0,group=d0))
  #g+geom_point()+geom_line()+geom_errorbar()+facet_grid(mode~span)+stdtheme
  g+geom_point()+geom_line()+geom_errorbar()+facet_wrap(~span,ncol = 7)+stdtheme
  ggsave(paste0(resdir,'laggedCorrs_',mode,'_Ncities',Ncities,'_Tw',Tw,'.pdf'),width=30,height=20,units='cm')
}


sres = data.frame()
for(d0 in d0s){
  sres=rbind(sres,cbind(d0=rep(d0,10),as.tbl(res[res$d0==d0,])%>%group_by(Tw)%>%summarise(signcorrs=length(which(rho!=0))/length(which(!is.na(rho))))))
}

g=ggplot(sres,aes(x=Tw,y=signcorrs,color=d0,group=d0))
g+geom_point()+geom_line()+stdtheme+ylab("% Significant Correlations")+xlab(expression(T[w]))
ggsave(paste0(resdir,'significantcorrs_Ncities',Ncities,'_Tw.pdf'),width=15,height=12,units='cm')

g=ggplot(sres,aes(x=d0,y=signcorrs,color=Tw,group=Tw))
g+geom_point()+geom_line()+stdtheme+ylab("% Significant Correlations")+xlab(expression(d[0]))+scale_x_log10()
ggsave(paste0(resdir,'significantcorrs_Ncities',Ncities,'_d0.pdf'),width=15,height=12,units='cm')


# -> correlations become less significant with distance -> spatial stationarity effect.
#

sres = data.frame()
for(d0 in d0s){
  sres=rbind(sres,cbind(d0=rep(d0,10),as.tbl(res[res$d0==d0,])%>%group_by(Tw)%>%summarise(meancorr=mean(rho[rho!=0]),meanabscorr=mean(abs(rho[rho!=0])))))
}

g=ggplot(sres,aes(x=Tw,y=meancorr,color=d0,group=d0))
g+geom_point()+geom_line()
ggsave(paste0(resdir,'meancorrs.pdf'),width=15,height=10,units='cm')

g=ggplot(sres,aes(x=Tw,y=meanabscorr,color=d0,group=d0))
g+geom_point()+geom_line()
ggsave(paste0(resdir,'meanabscorrs.pdf'),width=15,height=10,units='cm')



#####
# Spatial correlations


corrs = getSpatialCorrs(citydata,distmats)

g = ggplot(corrs)
g+geom_smooth(aes(x=distance,y=corrs,colour=years))+xlab("distance")+ylab("correlations")+stdtheme
ggsave(paste0(resdir,'distcorrs_realnw.pdf'),width=15,height=10,units='cm')







