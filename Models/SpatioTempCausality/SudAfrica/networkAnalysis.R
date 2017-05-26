

library(dplyr)
library(igraph)
library(ggplot2)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/SpatioTempCausality/SudAfrica'))

resdir = paste0(Sys.getenv('CN_HOME'),'/Results/SpatioTempCausality/SudAfrica/')

source("network.R")
source("networkMeasures.R")



###########
# evolution of network measures

measures <- c(gamma,normalizedBetweenness,shortestPathMeasures,clustCoef,louvainModularity)

cyears=c();cmeasures=c();cvals=c()
for(year in years){
  load(paste0('data/network',year,'.RData'))
  E(currentnetwork)$weight = 1/E(currentnetwork)$length
  for(measure in measures){
    vals = measure(currentnetwork)
    for(resname in names(vals)){
      cvals = append(cvals,vals[[resname]]);cyears=append(cyears,year);cmeasures=append(cmeasures,resname)
    }
  }
}

res = data.frame(year=cyears,measure=cmeasures,val=cvals)

g=ggplot(res,aes(x=year,y=val,color=measure,group=measure))
g+geom_point()+geom_line()

g=ggplot(res[!res$measure%in%c("diameter","vcount","ecount","mu","meanDegree","modularity"),],aes(x=year,y=val,color=measure,group=measure))
g+geom_point()+geom_line()

g=ggplot(res[res$measure%in%c("vcount","ecount"),],aes(x=year,y=val,color=measure,group=measure))
g+geom_point()+geom_line()+ylab('measure')
ggsave(paste0(resdir,'nwSize.pdf'),width=15,height=10,units = 'cm')


g=ggplot(res[res$measure%in%c("alphaBetweenness","alphaCloseness"),],aes(x=year,y=val,color=measure,group=measure))
g+geom_point()+geom_line()+ylab('measure')
ggsave(paste0(resdir,'hierarchies_nw.pdf'),width=15,height=10,units = 'cm')

g=ggplot(res[res$measure%in%c("meanBetweenness"),],aes(x=year,y=val,color=measure,group=measure))
g+geom_point()+geom_line()+ylab('measure')
ggsave(paste0(resdir,'meanBetweenness.pdf'),width=15,height=10,units = 'cm')

g=ggplot(res[res$measure%in%c("meanCloseness"),],aes(x=year,y=val,color=measure,group=measure))
g+geom_point()+geom_line()+ylab('measure')
ggsave(paste0(resdir,'meanBetweenness.pdf'),width=15,height=10,units = 'cm')


g=ggplot(res[res$measure%in%c("efficiency"),],aes(x=year,y=val,color=measure,group=measure))
g+geom_point()+geom_line()+ylab('measure')
ggsave(paste0(resdir,'efficiency.pdf'),width=15,height=10,units = 'cm')


