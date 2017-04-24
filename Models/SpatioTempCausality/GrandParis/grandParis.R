

## Causality Analysis of Grand Paris Express

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/SpatioTempCausality/GrandParis'))

library(dplyr)
library(igraph)

##
# transportation network
load('data/networks.RData')



##
# transactions BIEN by iris

bien <- as.tbl(read.csv(file = paste0(Sys.getenv('CN_HOME'),'/Data/BIEN/BIEN_min-noquote.csv'),stringsAsFactors = F))
bien$REQ_PRIX=as.numeric(bien$REQ_PRIX)
bien$MTCRED=as.numeric(bien$MTCRED)

# a lot of transactions only after 2003, begin in 2003
years = 2003:2012
#nrow(bien[bien$annee%in%years])
#length(unique(bien$IRIS)) -> 5417
# filter on existing iris
bien=bien[sapply(bien$IRIS,nchar)==9&!is.na(bien$REQ_PRIX),]

transactions <- bien[bien$annee%in%years,] %>% group_by(annee,IRIS) %>% summarise(price=mean(REQ_PRIX,na.rm=T),credit=mean(MTCRED,na.rm=T),count=length(which(!is.na(REQ_PRIX))))

# do maps ?


# employments : communeBP -> EMP2006


# iris
iris <- readOGR('data/gis','irisidf')
communes <- readOGR('data/gis','communes')


# distance matrix

fromids = c();for(cp in iris$DCOMIRIS){if(length(which(V(tr_grandparisexpress)$IRIS==cp))>0){show(cp)};fromids=append(fromids,which(V(tr_grandparisexpress)$IRIS==cp))}
toids = c();for(cp in communes$INSEE_COMM){if(length(which(V(tr_grandparisexpress)$CP==cp))>0){show(cp)};toids=append(toids,which(V(tr_grandparisexpress)$CP==cp))}
distmat = distances(graph = tr_grandparisexpress,v = fromids,to = toids,weights = E(tr_grandparisexpress)$speed*E(tr_grandparisexpress)$length)








