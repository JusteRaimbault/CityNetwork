
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

populations <- data.frame()
for(year in years){
  agglos = as.tbl(read.csv(paste0(popdatadir,'/',year,'_agglo.csv'),sep=';',stringsAsFactors = F,dec = ','))
  cities = as.tbl(read.csv(paste0(popdatadir,'/',year,'_ville.csv'),sep=';',stringsAsFactors = F,dec = ','))
  #show(as.numeric(agglos$ANNEE))
  agglos = agglos[,c(1,2,5,6,7)];names(agglos)<-c("id","name","year","agglo","pop")
  cities=cities[,c(1,2,5,6)];names(cities)<-c("id","name","agglo","pop")
  cities$year = rep(year,nrow(cities))
  populations=rbind(populations,agglos)
  populations=rbind(populations,cities[,colnames(agglos)])
}

save(populations,file='data/pops.RData')



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
  
# distance matrices

distmats = list()
for(year in years){
  load(paste0('data/network',year,'.RData'))
  E(currentnetwork)$weight = 1/E(currentnetwork)$length
  distmat = distances(currentnetwork,v=which(!is.na(V(currentnetwork)$ident)),to=which(!is.na(V(currentnetwork)$ident)))
  rownames(distmat)<-V(currentnetwork)$ident[!is.na(V(currentnetwork)$ident)]
  colnames(distmat)<-V(currentnetwork)$ident[!is.na(V(currentnetwork)$ident)]
  distmats[[as.character(year)]]<-distmat
}

save(distmats,file='data/distmats.RData')





