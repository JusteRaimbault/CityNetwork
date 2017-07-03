
##
# Causality Analysis of Grand Paris Express

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/SpatioTempCausality/GrandParis'))

library(dplyr)
library(igraph)
library(rgdal)
library(ggplot2)

source('functions.R')

##
# transportation network
load('data/networks.RData')



##
# transactions BIEN by iris

#bien <- as.tbl(read.csv(file = paste0(Sys.getenv('CN_HOME'),'/Data/BIEN/BIEN_min-noquote.csv'),stringsAsFactors = F))
#bien$REQ_PRIX=as.numeric(bien$REQ_PRIX)
#bien$MTCRED=as.numeric(bien$MTCRED)

# a lot of transactions only after 2003, begin in 2003
years = 2003:2012
#nrow(bien[bien$annee%in%years])
#length(unique(bien$IRIS)) -> 5417
# filter on existing iris
#bien=bien[sapply(bien$IRIS,nchar)==9&!is.na(bien$REQ_PRIX),]

#transactions <- bien[bien$annee%in%years,] %>% group_by(annee,IRIS) %>% summarise(price=mean(REQ_PRIX,na.rm=T),credit=mean(MTCRED,na.rm=T),count=length(which(!is.na(REQ_PRIX))))
#transactions$annee = sapply(as.character(transactions$annee),function(s){substr(s,3,4)})
#save(transactions,file='data/transactions.RData')
load('data/transactions.RData')

# - do some maps  - 

## accessibility data

# population
popyears = c(paste0("0",c(1:2,4:9)),"10","11")
pops = data.frame();incomes=data.frame();ginis=data.frame()
for(year in popyears){
  currentdata = read.table(file=paste0('data/pop/revenus',year,'.csv'),sep=";",header=T,stringsAsFactors = F,dec = ',')
  pops=rbind(pops,data.frame(id=as.character(currentdata$IRIS),var=currentdata[,paste0("NBUC",year)],year = rep(year,nrow(currentdata))))
  incomes=rbind(incomes,data.frame(id=as.character(currentdata$IRIS),var=currentdata[,paste0("RFUCQ2",year)],year = rep(year,nrow(currentdata))))
  ginis=rbind(ginis,data.frame(id=as.character(currentdata$IRIS),var=currentdata[,paste0("RFUCGI",year)],year = rep(year,nrow(currentdata))))
}
pops$year=as.character(pops$year);incomes$year=as.character(incomes$year);ginis$year=as.character(ginis$year);
pops$id=as.character(pops$id);incomes$id=as.character(incomes$id);ginis$id=as.character(ginis$id);


# employments : communeBP -> EMP2006
communesBP <- readOGR('data/gis','communesBP')
employment <- data.frame(id=communesBP$INSEE_COM,var=communesBP$EMP2006)
employment$id=as.character(employment$id)

# iris
iris <- readOGR('data/gis','irisidf')
communes <- readOGR('data/gis','communes')

# distance matrices
load('data/dmats.RData')


#


#

decays = c(5,10,20,30,45,60,120)
dmats_withbase = list(dmat_arcexpressloin,dmat_arcexpressproche,dmat_base,dmat_grandparisexpress,dmat_reseaugrandparis)
names(dmats_withbase)<-c("arcexpressloin","arcexpressproche","base","grandparisexpress","reseaugrandparis")

dmats= list(dmat_arcexpressloin,dmat_arcexpressproche,dmat_grandparisexpress,dmat_reseaugrandparis)
names(dmats)<-c("arcexpressloin","arcexpressproche","grandparisexpress","reseaugrandparis")
breakyears<-list("arcexpressloin"="06","arcexpressproche"="06","grandparisexpress"="10","reseaugrandparis"="08")

yvars = c("price","credit","count")

corrs = data.frame();vars=c();cdecays=c();network=c();cyvars=c()
for(yvar in yvars){
  ydata = transactions[,c("annee","IRIS",yvar)];names(ydata)<-c("year","id","var")
  for(mat in names(dmats)){
    for(decay in decays){
      show(decay)
      corrs=rbind(corrs,getLaggedCorrs(pops,employment,exp(-dmats[[mat]]/decay),ydata))
      corrs=rbind(corrs,getLaggedCorrs(incomes,employment,list(exp(-dmats[[mat]]/decay)),ydata))
      corrs=rbind(corrs,getLaggedCorrs(ginis,employment,list(exp(-dmats[[mat]]/decay)),ydata))
      vars=append(vars,c(rep("pop",11),rep("income",11),rep("gini",11)));
      cdecays=append(cdecays,rep(decay,33));network=append(network,rep(mat,33));cyvars=append(cyvars,rep(yvar,33))
    }
  }
}
d = data.frame(corrs,var=vars,decay=cdecays,network=network,yvar=cyvars)
#save(d,file='res/res.RData')
d$vars=paste0(d$var,'-',d$yvar)

resdir = paste0(Sys.getenv('CN_HOME'),'/Results/SpatioTempCausality/GrandParis/')

g=ggplot(d,aes(x=tau,y=rho,colour=decay,group=decay))
g+geom_line()+geom_point()+geom_errorbar(aes(ymin=rhomin,ymax=rhomax))+facet_grid(network~vars)
ggsave(file=paste0(resdir,'laggedcorrs_access.pdf'),width=30,height=20,unit='cm')



# Network modifications : 
#  - all sames with ∆ baseline
#  - same with travel time only (to isolate network effect)
#

# travel time only, with time-varying nw
# TODO : Q : influence of estimation window ? (fixed length ?)
nwyears = unique(transactions$annee)
# ones to have travel time only in accessibility
irisyears = c();for(year in nwyears){irisyears=append(irisyears,rep(year,length(iris)))}
irisunit = data.frame(id=rep(as.character(iris$DCOMIRIS),length(nwyears)),year=irisyears,var=rep(1,length(irisyears)))
irisunit$id = as.character(irisunit$id);irisunit$year=as.character(irisunit$year)
comyears = c();for(year in nwyears){comyears=append(comyears,rep(year,length(communes)))}
comunit = data.frame(id=rep(as.character(communes$INSEE_COMM),length(nwyears)),year=comyears,var=rep(1,length(comyears)))
comunit$id = as.character(comunit$id);comunit$year=as.character(comunit$year)

decays = c(10,30,60,120)
supyvars = list(pops,incomes,ginis)
names(supyvars)<-c("pop","income","gini")

#yvars = c("price","credit","count")
yvars = c("pop","income","gini")


corrs = data.frame();vars=c();cdecays=c();network=c();cyvars=c()
for(yvar in yvars){
  show(yvar)
  #ydata = transactions[,c("annee","IRIS",yvar)];names(ydata)<-c("year","id","var")
  ydata = supyvars[[yvar]]
  for(mat in names(dmats)){
    show(mat)
    for(decay in decays){
      show(decay)
      corrs=rbind(corrs,getLaggedCorrs(irisunit,comunit,varyingNetwork(dmats[[mat]],decay,breakyears[[mat]]),ydata))
      vars=append(vars,c(rep("traveltime",11)));cdecays=append(cdecays,rep(decay,11));network=append(network,rep(mat,11));cyvars=append(cyvars,rep(yvar,11))
    }
  }
}
dd = data.frame(corrs,var=vars,decay=cdecays,network=network,yvar=cyvars)
#save(dd,file='res/res_times_sup.RData')
#load('res/res_times_sup.RData');load('res/res_times.RData')
d=rbind(d,dd);d$yvar=as.character(d$yvar)

g=ggplot(d[!is.na(d$rho)&!(d$yvar%in%c("count")),],
         aes(x=tau,y=rho,ymin=rhomin,ymax=rhomax,colour=decay,group=decay))
g+geom_point()+geom_line()+geom_errorbar()+facet_grid(yvar~network,scales ="free")
ggsave(file=paste0(resdir,'laggedcorrs_times_allvars.png'),width=22,height=20,unit='cm')








