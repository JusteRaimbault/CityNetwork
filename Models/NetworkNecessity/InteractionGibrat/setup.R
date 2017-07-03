
# setup

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

alpha0=4;n0=3
load(paste0('data/distMat_Ncities',Ncities,'_alpha0',alpha0,'_n0',n0,'.RData'))
dists[dists==0]=1e8

## pop matrix
real_populations = as.matrix(cities[,4:ncol(cities)])
colnames(real_populations)<-dates

# export time periods to fit
periods = list("1831-1851"=1:5,"1841-1861"=3:7,"1851-1872"=5:9,"1861-1881"=7:11,"1872-1891"=9:13,
               "1881-1901"=11:15,"1891-1911"=13:17,"1921-1936"=18:21,"1946-1968"=c(23,24,26,27),"1962-1982"=26:29,
               "1975-1990"=28:31)

