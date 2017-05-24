
#####
# Sud-afriquie case study
#  data preparation

library(dplyr)
library(rgdal)
library(rgeos)
library(igraph)
library(ggplot2)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/SpatioTempCausality/SudAfrica'))

nwdir = paste0(Sys.getenv('CN_HOME'),'/Data/SudAfrica/BDD_SA_reseau')

resdir = paste0(Sys.getenv('CN_HOME'),'/Results/SpatioTempCausality/SudAfrica/')

source("network.R")
source("networkMeasures.R")

# population

popdatadir = paste0(Sys.getenv('CN_HOME'),'/Data/SudAfrica/pop')
years = c(1911,1921,1936,1951,1960,1970,1980,1991)

for(year in years){
  agglos = as.tbl(read.csv(paste0(popdatadir,'/',year,'_agglo.csv'),sep=';'))
  
}



# rank-size test
#plot(log(1:length(unique(agglos$pop_agglo_11))),log(sort(unique(agglos$pop_agglo_11),decreasing = T)))


# network

stations = readOGR(nwdir,'STATIONS')
troncons = readOGR(nwdir,'TRONCONS')
troncons@data$CLOSED[troncons@data$CLOSED==0]=3000

for(year in years){
  currentstations = stations[stations$OPENED<=year&stations$CLOSED>year,]
  currenttroncons = troncons[troncons$OPENED<=year&troncons$CLOSED>year,]
  currentnetwork = addTransportationLayer(currentstations,currenttroncons,speed=6e-04,snap = 0.01)
  save(currentnetwork,file=paste0('data/network',year,'.RData'))
}
  


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


