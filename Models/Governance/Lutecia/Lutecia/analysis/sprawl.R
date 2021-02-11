library(dplyr)
library(ggplot2)
library(reshape2)

setwd(paste0(Sys.getenv('CN_HOME'),'/Results/Governance/'))
source(paste0(Sys.getenv('CN_HOME'),'/Models/Governance/Lutecia/Lutecia/analysis/functions.R'))
source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

#resdir = '20170528_real'
#resdir = '20171219_sprawl/'
#resdir = '20170522_realnonw/'
resdir='20180205_localsynth/'
#res <- as.tbl(read.csv(file = '20170523_sprawl/data/20170523_150406_grid_sprawl.csv',sep=',',header=F,stringsAsFactors = F,skip = 1))
#res <- as.tbl(read.csv(file = '20170522_realnonw/data/20170522_174903_grid_realnonw_full.csv',sep=',',header=F,stringsAsFactors = F,skip = 1))
#res <- as.tbl(read.csv(file = '20171219_sprawl/data/20171219_164732_grid_sprawl.csv',sep=',',header=F,stringsAsFactors = F,skip = 1))
res <- as.tbl(read.csv(file = '20180205_localsynth/data/20180205_113455_local_synth.csv',sep=',',header=T,stringsAsFactors = F))



#finalTime = 50
#finalTime = 10
finalTime = 20

# NAMES IF NOT DEFINED
# names(res)<-namesTS(c("accessibilityTS","betaDC","centreActivesPropTS","centreEmploymentsPropTS"
#              ,"collcost","constrcost","entropyActivesTS","entropyEmploymentsTS",
#              "euclpace","evolveLanduse","evolveNetwork","expcollab","failed","finalTime","game","gametype",
#              "gammaCDA","gammaCDE","id","lambdaAcc","maxFlowTS","meanDistanceActivesTS",
#              "meanDistanceCentreActivesTS","meanDistanceCentreEmploymentsTS","meanDistanceEmploymentsTS",
#              "meanFlowTS","minFlowTS","moranActivesTS","moranEmploymentsTS","nwBetweenness",
#              "nwCloseness","nwDiameter","nwLength","nwPathLength","nwRelativeSpeed","realcollab",
#              "regionalproba","relDiffActivesTS","relDiffEmploymentsTS","replication","setupType",
#              "slopeActivesTS","slopeEmploymentsTS","slopeRsquaredActivesTS",
#              "slopeRsquaredEmploymentsTS","stabilityTS","synthConfFile","targetDistance","targetNetwork",
#              "traveldistanceTS","wantedcollab"
#              ),finalTime)



#
# 19 TS variables + 29 others -> 219 ?
# -> 229 : 13064 / 25000

##
# morpho trajectories
morphoActivesVars <- c(
  "moranActives","entropyActives","meanDistanceActives","slopeActives"
)
morphoEmploymentsVars <- c(
  "moranEmployments","entropyEmployments","meanDistanceEmployments","slopeEmployments"
)
params <- c("id","betaDC","gammaCDA","gammaCDE","lambdaAcc","euclpace","synthConfFile","nwLength")

#melt(res[,morphoVars],id.vars="id")
#morpho = res[,c(params,morphoVars)]

morphoActivesTS = data.frame()
morphoEmploymentsTS = data.frame()
for(t in 1:finalTime){
  show(t)
  currentd = res[,c(params,paste0(morphoActivesVars,"TS",t))]
  names(currentd)<-c(params,morphoActivesVars)
  morphoActivesTS = rbind(morphoActivesTS,cbind(currentd,time=rep(t,nrow(currentd))))
  currentd = res[,c(params,paste0(morphoEmploymentsVars,"TS",t))]
  names(currentd)<-c(params,morphoEmploymentsVars)
  morphoEmploymentsTS = rbind(morphoEmploymentsTS,cbind(currentd,time=rep(t,nrow(currentd))))
}

for(var in morphoActivesVars){morphoActivesTS[,var]<-(morphoActivesTS[,var]-min(morphoActivesTS[,var]))/(max(morphoActivesTS[,var])-min(morphoActivesTS[,var]))}
pca = prcomp(morphoActivesTS[,morphoActivesVars])
#write.table(pca$rotation,file=paste0(resdir,"pca-morphoActives.csv"),col.names = T,row.names = T)

morphoActivesTS=cbind(as.tbl(morphoActivesTS),as.tbl(as.data.frame(as.matrix(morphoActivesTS[,morphoActivesVars])%*%pca$rotation)))

sres = as.tbl(morphoActivesTS)%>% group_by(id,time)%>%summarise(
  PC1=mean(PC1),PC2=mean(PC2), betaDC=mean(betaDC),gammaCDA=mean(gammaCDA),
  gammaCDE=mean(gammaCDE),lambdaAcc=mean(lambdaAcc),euclpace=mean(euclpace),
  synthConfFile=synthConfFile[1],nwLength=mean(nwLength))

# plot trajectories
gammaCDA=0.9;gammaCDE=0.6
dir.create(paste0(resdir,'morphoActiveTrajs_gammaCDA',gammaCDA,'_gammaCDE',gammaCDE))
for(betaDC in unique(sres$betaDC)){for(euclpace in unique(sres$euclpace)){
  #for(conf in c("synth_nonw","synth_cross","synth_spider")){
#betaDC = 1.0;euclpace = 6.0;conf="setup/conf/synth_nonw.conf"
#lambdaAcc = 0.002
g=ggplot(sres[sres$gammaCDA==gammaCDA&sres$gammaCDE==gammaCDE&sres$betaDC==betaDC&sres$euclpace==euclpace,]#&sres$synthConfFile==paste0("setup/conf/",conf,".conf"),]
         ,aes(x=PC1,y=PC2,group=id,colour=lambdaAcc))
g+geom_point(size=0.1)+geom_path(arrow = arrow())+facet_wrap(~synthConfFile)#+facet_grid(gammaCDA~gammaCDE)
#ggsave(paste0(resdir,'morphoActiveTrajs_gammaCDA',gammaCDA,'_gammaCDE',gammaCDE,'/morphoActiveTrajsvaryinglambda_conf-',conf,"_betaDC",betaDC,"_euclpace",euclpace,'.pdf'),width = 30,height = 20,units = 'cm')
ggsave(paste0(resdir,'morphoActiveTrajs_gammaCDA',gammaCDA,'_gammaCDE',gammaCDE,'/morphoActiveTrajsvaryinglambda_betaDC',betaDC,"_euclpace",euclpace,'.pdf'),width = 30,height = 20,units = 'cm')

#}
  }}


# phase diagrams of final configuration

subresdir = paste0(resdir,'phasediagrams/');dir.create(subresdir)

for(euclpace in unique(sres$euclpace)){for(conffile in unique(sres$synthConfFile)){
  confname = strsplit(strsplit(conffile,"/",fixed=T)[[1]][3],'.',fixed=T)[[1]][1]
  g=ggplot(sres[sres$synthConfFile==conffile&sres$time==finalTime&sres$euclpace==euclpace,])
  g+geom_raster(aes(x=gammaCDA,y=gammaCDE,fill=PC1))+facet_grid(betaDC~lambdaAcc)+scale_fill_continuous(limits = c(min(sres$PC1),max(sres$PC1)))+
    xlab(expression(gamma[A]))+ylab(expression(gamma[E]))+stdtheme
  ggsave(paste0(subresdir,'PC1_',confname,'_euclpace',euclpace,'.png'),width=30,height=25,units='cm')
  #g+geom_line(aes(x=gammaCDA,y=PC1,colour=gammaCDE,group=gammaCDE))+facet_grid(betaDC~lambdaAcc,scales = "free")+
  #    xlab(expression(gamma[A]))+ylab("PC1")+stdtheme
}}



#######
## reldiff

res$cumreldiffactives = rowSums(res[,paste0("relDiffActivesTS",1:50)])
#summary(res%>%group_by(id)%>%summarise(count=n()))

for(euclpace in unique(res$euclpace)){for(conffile in unique(res$synthConfFile)){
  confname = strsplit(strsplit(conffile,"/",fixed=T)[[1]][3],'.',fixed=T)[[1]][1]
  g=ggplot(res)
  g+geom_raster(aes(x=gammaCDA,y=gammaCDE,fill=log(cumreldiffactives)))+facet_grid(betaDC~lambdaAcc)+scale_fill_continuous(name=expression(log*"("*tilde(Delta)*")"),limits = c(log(min(res$cumreldiffactives)),log(max(res$cumreldiffactives))))+
    xlab(expression(gamma[A]))+ylab(expression(gamma[E]))+stdtheme
  ggsave(paste0(subresdir,'rdiffact_',confname,'_euclpace',euclpace,'.png'),width=30,height=25,units='cm')
  }
}


summary(res$cumreldiffactives)

res[res$cumreldiffactives==min(res$cumreldiffactives),params]




#######
## metropolisation


resdir='20180205_localsynth/'
res <- as.tbl(read.csv(file = '20180205_localsynth/data/20180205_113455_local_synth.csv',sep=',',header=T,stringsAsFactors = F))
finalTime = 20


res$evolveLanduseF = ifelse(res$evolveLanduse==1,"With land-use","Without land-use")

g=ggplot(res,aes(x=regionalproba,y=accessibilityBalanceTS19/accessibilityBalanceTS0,colour = synthConfFile,group=synthConfFile))
g+geom_point(pch='.')+geom_smooth()+facet_wrap(~evolveLanduseF,scales = 'free')+
  #xlab(expression(xi))+ylab(expression(frac(X[0](t[f]),X[1](t[f]))%.%frac(X[1](t[0]),X[0](t[0]))))+
  xlab(expression(xi*' (% regional decisions)'))+ylab('Relative accessibility between centres')+
  scale_color_discrete(name='Configuration',labels=c('Close','Distant'))+stdtheme
ggsave(file=paste0(resdir,'accessbalance_en.png'),width=30,height=15,units='cm')

g=ggplot(res,aes(x=regionalproba,y=accessibilityTS19/accessibilityTS0,colour = synthConfFile,group=synthConfFile))
g+geom_point(pch='.')+geom_smooth()+facet_wrap(~evolveLanduseF,scales = 'free')+
  #xlab(expression(xi))+ylab(expression(frac(X(t[f]),X(t[0]))))+
  xlab(expression(xi*' (% regional decisions)'))+ylab('Total accessibility gain')+
  scale_color_discrete(name='Configuration',labels=c('Close','Distant'))+stdtheme
ggsave(file=paste0(resdir,'accesstot_en.png'),width=30,height=15,units='cm')


res$evolveLanduseF = ifelse(res$evolveLanduse==1,"Avec usage du sol","Sans usage du sol")

g=ggplot(res,aes(x=regionalproba,y=accessibilityBalanceTS19/accessibilityBalanceTS0,colour = synthConfFile,group=synthConfFile))
g+geom_point(pch='.')+geom_smooth()+facet_wrap(~evolveLanduseF,scales = 'free')+xlab(expression(xi))+
  ylab(expression(frac(X[0](t[f]),X[1](t[f]))%.%frac(X[1](t[0]),X[0](t[0]))))+
  scale_color_discrete(name='Configuration',labels=c('Proche','Distante'))+stdtheme
ggsave(file=paste0(resdir,'accessbalance.png'),width=30,height=15,units='cm')

g=ggplot(res,aes(x=regionalproba,y=accessibilityTS19/accessibilityTS0,colour = synthConfFile,group=synthConfFile))
g+geom_point(pch='.')+geom_smooth()+facet_wrap(~evolveLanduseF,scales = 'free')+xlab(expression(xi))+
  ylab(expression(frac(X(t[f]),X(t[0]))))+
  scale_color_discrete(name='Configuration',labels=c('Proche','Distante'))+stdtheme
ggsave(file=paste0(resdir,'accesstot.png'),width=30,height=15,units='cm')




