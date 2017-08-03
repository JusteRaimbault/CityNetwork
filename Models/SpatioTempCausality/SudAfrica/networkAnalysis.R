

library(dplyr)
library(igraph)
library(ggplot2)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/SpatioTempCausality/SudAfrica'))

resdir = paste0(Sys.getenv('CN_HOME'),'/Results/SpatioTempCausality/SudAfrica/')

source("network.R")
source("networkMeasures.R")
source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

years = c(1911,1921,1936,1951,1960,1970,1980,1991)

###########
# evolution of network measures

measures <- c(gamma,normalizedBetweenness,shortestPathMeasures,clustCoef,louvainModularity)

cyears=c();cmeasures=c();cvals=c()
#bws=c();bwyear=c()
for(year in years){
  load(paste0('data/network',year,'.RData'))
  E(currentnetwork)$weight = 1/E(currentnetwork)$length
  for(measure in measures){
    vals = measure(currentnetwork)
    for(resname in names(vals)){
      cvals = append(cvals,vals[[resname]]);cyears=append(cyears,year);cmeasures=append(cmeasures,resname)
    }
  }
  #currentbw = normalizedBetweenness(currentnetwork)
  #bws=append(bws,currentbw$bw);bwyear=append(bwyear,rep(year,length(currentbw$bw)))
}
res = data.frame(year=cyears,measure=cmeasures,val=cvals)


### graphs

# test smoothed bw
#g=ggplot(data.frame(bw=bws,year=bwyear),aes(x=year,y=bw))
#g+geom_point(pch='.')+stat_smooth(method = 'loess')

#g=ggplot(res,aes(x=year,y=val,color=measure,group=measure))
#g+geom_point()+geom_line()

#g=ggplot(res[!res$measure%in%c("diameter","vcount","ecount","mu","meanDegree","modularity"),],aes(x=year,y=val,color=measure,group=measure))
#g+geom_point()+geom_line()

g=ggplot(res[res$measure%in%c("vcount","ecount"),],aes(x=year,y=val,color=measure,group=measure))
g+geom_point()+geom_line()+ylab('Network size')+stdtheme
ggsave(paste0(resdir,'nw_nwSize.pdf'),width=18,height=11,units = 'cm')

# normalize centralities ? no, bw quite stable indeed
#res$val[res$measure=="alphaBetweenness"]

g=ggplot(res[res$measure%in%c("alphaBetweenness","alphaCloseness"),],aes(x=year,y=val,color=measure,group=measure))
g+geom_point()+geom_line()+ylab('Hierarchy of centralities')+stdtheme
ggsave(paste0(resdir,'nw_hierarchies.pdf'),width=20,height=11,units = 'cm')

#g=ggplot(data.frame(bw=res$val[res$measure%in%c("meanBetweenness")],year=res$year[res$measure%in%c("meanBetweenness")],std=res$val[res$measure%in%c("stdBetweenness")]),aes(x=year,y=bw,ymin=bw-std,ymax=bw+std))
#g+geom_point()+geom_line()+geom_errorbar()+ylab('Betweenness centrality')
#g=ggplot(data.frame(bw=res$val[res$measure%in%c("meanBetweenness")],year=res$year[res$measure%in%c("meanBetweenness")]),aes(x=year,y=bw))
#g+geom_point()+geom_line()+ylab('Betweenness centrality')
#ggsave(paste0(resdir,'meanBetweenness.pdf'),width=15,height=10,units = 'cm')

# normalize the means
max(res$val[res$measure=="meanBetweenness"])
max(res$val[res$measure=="meanCloseness"])
res$val[res$measure=="meanBetweenness"]=(res$val[res$measure=="meanBetweenness"]-min(res$val[res$measure=="meanBetweenness"]))/(max(res$val[res$measure=="meanBetweenness"])-min(res$val[res$measure=="meanBetweenness"]))
res$val[res$measure=="meanCloseness"]=(res$val[res$measure=="meanCloseness"]-min(res$val[res$measure=="meanCloseness"]))/(max(res$val[res$measure=="meanCloseness"])-min(res$val[res$measure=="meanCloseness"]))

g=ggplot(res[res$measure%in%c("meanCloseness","meanBetweenness"),],aes(x=year,y=val,color=measure,group=measure))
g+geom_point()+geom_line()+ylab('Normalized centralities')+stdtheme
ggsave(paste0(resdir,'nw_meanCentralities.pdf'),width=20,height=11,units = 'cm')


g=ggplot(res[res$measure%in%c("efficiency"),],aes(x=year,y=val))
g+geom_point()+geom_line()+ylab('Efficiency')+stdtheme
ggsave(paste0(resdir,'nw_efficiency.pdf'),width=15,height=10,units = 'cm')


