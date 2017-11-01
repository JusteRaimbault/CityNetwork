
##
# Causality Analysis of Grand Paris Express

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/SpatioTempCausality/GrandParis'))

library(dplyr)
library(igraph)
library(rgdal)
library(ggplot2)

source('../functions.R')

##
# transportation network
load('data/networks2.RData')

##
# transactions BIEN by iris
years = 2003:2012
load('data/transactions.RData')

## accessibility data
load('data/socioeco.RData')

# distance matrices
load('data/dmats2.RData')



####
# Maps

png(filename = paste0(Sys.getenv('CN_HOME'),'/Results/SpatioTempCausality/GrandParis/networks/grandparisexpress.png'),width=30,height=30,units='cm',res=600)
plot(tr_grandparisexpress,vertex.size=0.3,vertex.label=NA,edge.color='grey',edge.width=0.2,rescale=T)
dev.off()

png(filename = paste0(Sys.getenv('CN_HOME'),'/Results/SpatioTempCausality/GrandParis/networks/base.png'),width=30,height=30,units='cm',res=600)
plot(tr_base,vertex.size=0.3,vertex.label=NA,edge.color='grey',edge.width=0.2,rescale=T)
dev.off()

# accessibility in 2012, without GPE, and Delta acc ; for different decays
resdir = paste0(Sys.getenv('CN_HOME'),'/Results/SpatioTempCausality/GrandParis/maps/')

# tests
plot(iris[which(!iris$DCOMIRIS%in%pops$id),])
ext = as.tbl(read.csv(file=paste0(Sys.getenv('CS_HOME'),'/RobustnessDiscrepancy/Data/raw/iris/structure-distrib-revenus-iris-2011/RFDM2011IRI.csv'),sep=';'))
plot(iris[which(!iris$DCOMIRIS%in%ext$IRIS),])
extcom = as.tbl(read.csv(file=paste0(Sys.getenv('CS_HOME'),'/RobustnessDiscrepancy/Data/raw/iris/structure-distrib-revenus-com-2011/RFDU2011COM.csv'),sep=';',dec = ','))
plot(iris[which(iris$DCOMIRIS%in%paste0(as.character(extcom$COM),'0000')),])
plot(iris[which(!iris$DCOMIRIS%in%paste0(as.character(extcom$COM),'0000')),],col='red',add=T)
rows = which(paste0(as.character(extcom$COM),'0000')%in%iris$DCOMIRIS)
pops=rbind(pops,data.frame(id=paste0(as.character(extcom$COM),'0000')[rows],var=extcom$NBUC11[rows],year=rep('11',length(rows))))

source('../functions.R')

year='11'
currentpop=pops[pops$year==year,]
decay = 60
access = computeAccess(currentpop[currentpop$id%in%rownames(dmat_grandparisexpress),],employment,exp(-dmat_grandparisexpress/decay))
access$var = (access$var - min(access$var))/(max(access$var)-min(access$var))
toadd = as.character(iris$DCOMIRIS)[!as.character(iris$DCOMIRIS)%in%access$id]
access = rbind(access,data.frame(id=toadd,var=rep(NA,length(toadd)),year=rep(year,length(toadd))))# add missing iris with NA
map(data=access,layer=iris,spdfid="DCOMIRIS",dfid="id",variable="var",
    filename=paste0(resdir,'normaccess_gpe_',year,'_decay',decay,'.png'),title=paste0('Normalized Accessibility with GPE, Population to Employments, decay ',decay,', year 20',year),legendtitle = "Normalized\nAccessibility",extent=iris,
    width=15,height=12
    )


# time accessibility
time=computeAccess(data.frame(id=rownames(dmat_grandparisexpress),var=rep(1,nrow(dmat_grandparisexpress)),year=rep(year,nrow(dmat_grandparisexpress))),data.frame(id=colnames(dmat_grandparisexpress),var=rep(1/ncol(dmat_grandparisexpress),ncol(dmat_grandparisexpress))),dmat_grandparisexpress)
map(data=time,layer=iris,spdfid="DCOMIRIS",dfid="id",variable="var",
    filename=paste0(resdir,'timeaccess_gpe.png'),title=paste0('Time Accessibility with GPE'),legendtitle = "Average\nTravel Time",extent=iris,
    width=15,height=12
)

# time accessibility without GPE
time=computeAccess(data.frame(id=rownames(dmat_base),var=rep(1,nrow(dmat_base)),year=rep(year,nrow(dmat_base))),data.frame(id=colnames(dmat_base),var=rep(1/ncol(dmat_base),ncol(dmat_base))),dmat_base)
map(data=time,layer=iris,spdfid="DCOMIRIS",dfid="id",variable="var",
    filename=paste0(resdir,'timeaccess.png'),title=paste0('Time Accessibility without GPE'),legendtitle = "Average\nTravel Time",extent=iris,
    width=15,height=12
)


# time differential with/without GPE
timediff=dmat_base-dmat_grandparisexpress
summary(c(timediff))
time=computeAccess(data.frame(id=rownames(dmat_base),var=rep(1,nrow(dmat_base)),year=rep(year,nrow(dmat_base))),data.frame(id=colnames(dmat_base),var=rep(1/ncol(dmat_base),ncol(dmat_base))),timediff)
map(data=time,layer=iris,spdfid="DCOMIRIS",dfid="id",variable="var",
    filename=paste0(resdir,'timegain.png'),title=paste0('Time Accessibility Gain'),legendtitle = "Average\nTime Gain",extent=iris,
    width=15,height=12,palette='div'
)


#####
# on Metropole only
depts=c("75","92","93","94")
iris = iris[substring(as.character(iris$DCOMIRIS),1,2)%in%depts,]

time=computeAccess(data.frame(id=rownames(dmat_grandparisexpress),var=rep(1,nrow(dmat_grandparisexpress)),year=rep(year,nrow(dmat_grandparisexpress))),data.frame(id=colnames(dmat_grandparisexpress),var=rep(1/ncol(dmat_grandparisexpress),ncol(dmat_grandparisexpress))),dmat_grandparisexpress)
map(data=time[time$id%in%iris$DCOMIRIS,],layer=iris,spdfid="DCOMIRIS",dfid="id",variable="var",
    filename=paste0(resdir,'timeaccess_gpe_metropole.png'),title=paste0('Time Accessibility with GPE'),legendtitle = "Average\nTravel Time",extent=iris,
    width=15,height=12
)

time=computeAccess(data.frame(id=rownames(dmat_grandparisexpress),var=rep(1,nrow(dmat_grandparisexpress)),year=rep(year,nrow(dmat_grandparisexpress))),data.frame(id=colnames(dmat_grandparisexpress),var=rep(1/ncol(dmat_grandparisexpress),ncol(dmat_grandparisexpress))),dmat_base)
map(data=time[time$id%in%iris$DCOMIRIS,],layer=iris,spdfid="DCOMIRIS",dfid="id",variable="var",
    filename=paste0(resdir,'timeaccess_metropole.png'),title=paste0('Time Accessibility without GPE'),legendtitle = "Average\nTravel Time",extent=iris,
    width=15,height=12
)

time_withoutgpe = time

timediff=dmat_base-dmat_grandparisexpress;timediff[timediff<0]=0
time=computeAccess(data.frame(id=rownames(dmat_base),var=rep(1,nrow(dmat_base)),year=rep(year,nrow(dmat_base))),data.frame(id=colnames(dmat_base),var=rep(1/ncol(dmat_base),ncol(dmat_base))),timediff)

map(data=time[time$id%in%iris$DCOMIRIS,],layer=iris,spdfid="DCOMIRIS",dfid="id",variable="var",
    filename=paste0(resdir,'timegain_metropole.png'),title=paste0('Time Accessibility Gain'),legendtitle = "Average\nTime Gain",extent=iris,
    width=15,height=12,palette='div',lwd=0.2,
    additionalPointlayers=list(readOGR('data/gis','grandparisexpress_gares')),
    additionalLinelayers=list(readOGR('data/gis','grandparisexpress'))
)


## classif / average

source('../functions.R')

classif = data.frame(
  classification = paste0(
  ifelse(time$var[time$id%in%iris$DCOMIRIS] - median(time$var[time$id%in%iris$DCOMIRIS])>0,'gain fort','gain faible'),rep('/',nrow(time)),
  ifelse(time_withoutgpe$var[time_withoutgpe$id%in%iris$DCOMIRIS] - median(time_withoutgpe$var[time_withoutgpe$id%in%iris$DCOMIRIS])>0,'access. faible','access. forte')
  ),
  id=time$id
)

map(data=classif,layer=iris,spdfid="DCOMIRIS",dfid="id",variable="classification",
    filename=paste0(resdir,'timeclassif_metropole.png'),title=paste0("Profils d'accessibilite temporelle"),legendtitle = "Profil",extent=iris,
    width=15,height=12,palette='div',lwd=0.2,
    additionalPointlayers=list(list(readOGR('data/gis','grandparisexpress_gares'),'blue')),
    additionalLinelayers=list(list(communes[substr(as.character(communes$INSEE_COMM),1,2)%in%depts,],'black'),list(readOGR('data/gis','grandparisexpress'),'blue')),
    withScale=0
)

#####
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
      corrs=rbind(corrs,getLaggedCorrsDeltas(pops,employment,exp(-dmats[[mat]]/decay),ydata))
      corrs=rbind(corrs,getLaggedCorrsDeltas(incomes,employment,list(exp(-dmats[[mat]]/decay)),ydata))
      corrs=rbind(corrs,getLaggedCorrsDeltas(ginis,employment,list(exp(-dmats[[mat]]/decay)),ydata))
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
#  - all sames with ??? baseline
#  - same with travel time only (to isolate network effect)
#

# travel time only, with time-varying nw
# Q : influence of estimation window ? (fixed length ?) -> full length too short to have moving window here
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
      corrs=rbind(corrs,getLaggedCorrsDeltas(irisunit,comunit,varyingNetwork(dmats[[mat]],decay,breakyears[[mat]]),ydata))
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








