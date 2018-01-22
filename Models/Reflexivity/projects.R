
library(dplyr)
library(ggplot2)
library(reshape2)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/Reflexivity'))

time <- as.tbl(read.csv(file='data/time.csv',header = T,sep = ";",dec = ",",na.strings = c("")))
tmat = t(as.matrix(time[,2:ncol(time)]))
colnames(tmat)<-time$Project.Name
dates=rev(as.POSIXct(seq(from=format(as.POSIXct("2015/02/16"),"%s"),to=format(as.POSIXct("2017/12/02"),"%s"),by=86400),origin =strptime(0,format='%s')))
tmat=as.tbl(data.frame(tmat))
tmat$date = dates
tmat[is.na(tmat)]=0
  
#g=ggplot(melt(data=tmat,measure.vars = 1:(ncol(tmat)-1), id.vars = 'date'),aes(x=date,y=value))
#g+geom_area(aes(fill= variable), position = 'stack')+scale_fill_discrete(guide=FALSE)

# group by weeks

g=ggplot(melt(data=tmat,measure.vars = 1:(ncol(tmat)-1), id.vars = 'date'),aes(x=date,y=value,colour= variable,group=variable))
g+geom_smooth()+scale_colour_discrete(guide=FALSE)

# need to aggregate at a "macro-project" level







