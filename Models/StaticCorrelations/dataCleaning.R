
#load('res/res/20160826_parallcorrs_corrTest_unlisted.RData')

#show('data loaded...')

#rows=apply(allcorrs[,1:6],1,function(r){prod(as.numeric(!is.na(r)))>0})
#allcorrs=allcorrs[rows,]

#save(allcorrs,file='res/res/20160826_parallcorrs_corrTest_unlisted_nona.RData')


setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))
source('functions.R')

library(raster)
library(ggplot2)
library(dplyr)

load('res/res/20160826_parallcorrs_corrTest_unlisted_nona_goodCols.RData')

d=as.tbl(allcorrs[allcorrs$measure=='mean',])
#d=as.tbl(allcorrs)
d$rhomax=as.numeric(as.character(d$rhomax))
d$delta=as.numeric(as.character(d$delta))
d$measure=as.character(d$measure)
d$type=as.character(d$type)

#d=d[d$delta==4|d$delta==8|d$delta==12,]

#save(d,file='res/res/sample4-8-12.RData')

sumcorrsmean = as.tbl(d) %>% group_by(delta,type) %>% summarise(meanrho=mean(rho,na.rm=TRUE),rhosd=sd(rho,na.rm=TRUE))
sumcorrsmeanmin = as.tbl(d) %>% group_by(delta,type) %>% summarise(meanrho=mean(rhomin,na.rm=TRUE),rhosd=sd(rhomin,na.rm=TRUE))
sumcorrsmeanmax = as.tbl(d) %>% group_by(delta,type) %>% summarise(meanrho=mean(rhomax,na.rm=TRUE),rhosd=sd(rhomax,na.rm=TRUE))


d=as.tbl(allcorrs[allcorrs$measure=='meanabs',])
d$rhomax=as.numeric(as.character(d$rhomax))
d$delta=as.numeric(as.character(d$delta))
d$measure=as.character(d$measure)
d$type=as.character(d$type)

sumcorrsmeanabs = as.tbl(d) %>% group_by(delta,type) %>% summarise(meanrho=mean(rho,na.rm=TRUE),rhosd=sd(rho,na.rm=TRUE))
sumcorrsmeanabsmin = as.tbl(d) %>% group_by(delta,type) %>% summarise(meanrho=mean(rhomin,na.rm=TRUE),rhosd=sd(rhomin,na.rm=TRUE))
sumcorrsmeanabsmax = as.tbl(d) %>% group_by(delta,type) %>% summarise(meanrho=mean(rhomax,na.rm=TRUE),rhosd=sd(rhomax,na.rm=TRUE))

save(sumcorrsmean,sumcorrsmeanmin,sumcorrsmeanmax,sumcorrsmeanabs,sumcorrsmeanabsmin,sumcorrsmeanabsmax,file='res/res/sumcorrs.RData')





