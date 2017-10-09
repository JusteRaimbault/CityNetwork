
library(dplyr)
library(ggplot2)
library(reshape2)
library(rlang)
source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/Reproduction/SimpopNet'))

res <- as.tbl(read.csv('exploration/20171005_110203_GRIDLHS.csv',stringsAsFactors = FALSE,header=F,skip = 1))
resdir <- paste0(Sys.getenv('CN_HOME'),'/Results/Reproduction/SimpopNet/20171005_GRIDLHS/');dir.create(resdir)

finalTime = 100
samplingStep = 5
samplingTimes = seq(from=0,to=finalTime-samplingStep,by=samplingStep)
taumax = 6
lags = seq(from=-taumax,to=taumax,by=1)
distcorrbins = 1:10

timelyNames<-function(arraynames,samplingTimes){res=c();for(t in samplingTimes){res=append(res,paste0(arraynames,t))};return(res)}


#accessibilityEntropies,accessibilityHierarchies,accessibilitySummaries,
#closenessEntropies,closenessHierarchies,closenessSummaries,complexityAccessibility,complexityCloseness,
#complexityPop,diversityAccessibility,diversityCloseness,diversityPop,finalTime,gravityDecay,
#gravityGamma,id,networkGamma,networkSpeed,networkThreshold,nwDiameter,
#nwHierarchyBwCentrality,nwLength,nwMeanBwCentrality,nwMeanPathLength,nwRelativeSpeed,
#populationEntropies,populationHierarchies,populationSummaries,rankCorrAccessibility,rankCorrCloseness,
#rankCorrPop,replication,rhoClosenessAccessibility,rhoDistClosenessAccessibility,rhoDistPopAccessibility,
#rhoDistPopCloseness,rhoPopAccessibility,rhoPopCloseness,synthCities,synthMaxDegree,synthRankSize,
#synthShortcut,synthShortcutNum

names(res)<-c(
  timelyNames(c("accessibilityEntropies"),samplingTimes),
  timelyNames(c("accessibilityHierarchies_alpha","accessibilityHierarchies_rsquared"),samplingTimes),
  timelyNames(c("accessibilitySummaries_mean","accessibilitySummaries_median","accessibilitySummaries_sd"),samplingTimes),
  timelyNames(c("closenessEntropies"),samplingTimes),
  timelyNames(c("closenessHierarchies_alpha","closenessHierarchies_rsquared"),samplingTimes),
  timelyNames(c("closenessSummaries_mean","closenessSummaries_median","closenessSummaries_sd"),samplingTimes),
  "complexityAccessibility","complexityCloseness","complexityPop",
  "diversityAccessibility","diversityCloseness","diversityPop",
  "finalTime","gravityDecay","gravityGamma","id","networkGamma",
  "networkSpeed","networkThreshold","nwDiameter","nwHierarchyBwCentrality","nwLength","nwMeanBwCentrality",
  "nwMeanPathLength","nwRelativeSpeed",
  timelyNames(c("populationEntropies"),c(samplingTimes,finalTime)),
  timelyNames(c("populationHierarchies_alpha","populationHierarchies_rsquared"),c(samplingTimes,finalTime)),
  timelyNames(c("populationSummaries_mean","populationSummaries_median","populationSummaries_sd"),c(samplingTimes,finalTime)),
  "rankCorrAccessibility","rankCorrCloseness","rankCorrPop","replication",
  paste0("rhoClosenessAccessibility_tau",lags),
  paste0("rhoDistClosenessAccessibility",distcorrbins),
  paste0("rhoDistPopAccessibility",distcorrbins),paste0("rhoDistPopCloseness",distcorrbins),
  paste0("rhoPopAccessibility_tau",lags),paste0("rhoPopCloseness_tau",lags),
  "synthCities","synthMaxDegree","synthRankSize","synthShortcut","synthShortcutNum"
)

params = c("gravityDecay","gravityGamma","networkGamma","networkThreshold","networkSpeed")#,"synthRankSize","synthCities","synthShortcut","synthMaxDegree","synthShortcutNum")

vars = c("accessibilityEntropies95","accessibilityHierarchies_alpha95","accessibilitySummaries_mean95",
         "closenessEntropies95","closenessHierarchies_alpha95","closenessSummaries_mean95",
         "populationEntropies95","populationHierarchies_alpha95","populationSummaries_mean95",
         "complexityAccessibility","complexityCloseness","complexityPop",
         "diversityAccessibility","diversityCloseness","diversityPop"
         )

sres = res %>% group_by(synthCities,synthMaxDegree,synthRankSize,synthShortcut,synthShortcutNum) %>% summarise(count=n())


########
## 1) Variability

## sharpe repets vs phase diag (average on configs)
##  and repets vs all (eq to phase diag vs configs)

# check counts
sres=res%>%group_by(id)%>%summarise(count=n(),sdsynthCities=sd(synthCities))
#sres=res%>%group_by(id,confid)%>%summarise(count=n())
sres=res%>%group_by(replication)%>%summarise(count=n())

# variability across repets
source(paste0(Sys.getenv("CS_HOME"),'/SpaceMatters/Models/spacematters/Scripts/functions.R'))

res$pid = paste0(res$gravityDecay,res$gravityGamma,res$networkGamma,res$networkThreshold,res$networkSpeed)
res$confid = paste0(res$synthCities,"-",res$synthMaxDegree,"-",res$synthRankSize,"-",res$synthShortcut,"-",res$synthShortcutNum)

sres = res%>%group_by(gravityDecay,gravityGamma,networkGamma,networkThreshold,networkSpeed,synthCities,synthMaxDegree,synthRankSize,synthShortcut,synthShortcutNum)%>%summarise(
  accessibilityEntropies95=mean(accessibilityEntropies95),accessibilityHierarchies_alpha95=mean(accessibilityHierarchies_alpha95),accessibilitySummaries_mean95=mean(accessibilitySummaries_mean95),
  closenessEntropies95=mean(closenessEntropies95),closenessHierarchies_alpha95=mean(closenessHierarchies_alpha95),closenessSummaries_mean95=mean(closenessSummaries_mean95),
  populationEntropies95=mean(populationEntropies95),populationHierarchies_alpha95=mean(populationHierarchies_alpha95),populationSummaries_mean95=mean(populationSummaries_mean95),
  complexityAccessibility=mean(complexityAccessibility),complexityCloseness=mean(complexityCloseness),complexityPop=mean(complexityPop),
  diversityAccessibility=mean(diversityAccessibility),diversityCloseness=mean(diversityCloseness),diversityPop=mean(diversityPop),
  pid=pid[1],confid=confid[1]
  )

dists = distancesToRef(simresults=sres,reference=sres[sres$confid==sres$confid[1],],parameters=params,indicators=vars,idcol='confid')

# pretty print distances
paste0(sapply(strsplit(names(dists),'-',fixed=T),function(l){l[1]}),collapse = " & ")
#paste0(sapply(strsplit(names(dists),'-',fixed=T),function(l){l[2]}),collapse = " & ")
paste0(sapply(strsplit(names(dists),'-',fixed=T),function(l){l[3]}),collapse = " & ")
paste0(sapply(strsplit(names(dists),'-',fixed=T),function(l){l[4]}),collapse = " & ")
paste0(sapply(strsplit(names(dists),'-',fixed=T),function(l){l[5]}),collapse = " & ")
paste0(dists,collapse = ' & ')


#for(var in vars){
#  show(var)
#  sresrep = res[res$populationSummaries_mean95<1e8,] %>% group_by(id) %>% summarise(ratio=abs(mean(UQ(sym(var))))/sd(UQ(sym(var))),count=n())
#  #sresmeta = res %>% group_by(synthCities,synthMaxDegree,synthRankSize,synthShortcut,synthShortcutNum) %>% summarise(ratio=sd(UQ(sym(var)))/abs(mean(UQ(sym(var)))))
#  #ratio = sd(unlist(res[,var]))/abs(mean(unlist(res[,var])))
#  show(min(sresrep$count))
#  show(summary(sresrep$ratio))
#  #show(paste0(var,", rep : ",mean(sresrep$ratio)/ratio))
#  #show(paste0(var,",phasediag : ",mean(sresmeta$ratio)/ratio))
#}



##################
##################

synthCities=80;synthRankSize=0.5;synthShortcut=10;synthShortcutNum=30;networkSpeed=60
currentdata = res[res$networkThreshold>1&res$synthCities==synthCities&res$synthRankSize==synthRankSize&res$synthShortcut==synthShortcut&res$synthShortcutNum==synthShortcutNum&res$networkSpeed==networkSpeed,]
#currentdata = res[res$synthCities==synthCities&res$synthRankSize==synthRankSize&res$synthShortcut==synthShortcut&res$synthShortcutNum==synthShortcutNum&res$networkSpeed==networkSpeed,]

dir.create(paste0(resdir,'complexity'))

vars = c("Accessibility","Closeness","Pop")
measures = c("complexity","diversity","rankCorr")

for(var in vars){
  for(mes in measures){
    show(paste0(mes,var))
    g=ggplot(currentdata,aes_string(x="gravityDecay",y=paste0(mes,var),color="gravityGamma",group="gravityGamma"))
    g+geom_point()+stat_smooth(span=1)+
      facet_grid(networkGamma~networkThreshold,scales="free")#+ggtitle(paste0("synthrankSize=",synthrankSize," ; nwGmax=",nwGmax))#+stdtheme
    ggsave(paste0(resdir,'complexity/',mes,var,'_synthRankSize',synthRankSize,'_networkSpeed',networkSpeed,'.pdf'),width=30,height=20,units='cm')
    #}
  }
}



##################
##################

# traj in time

vars = c("accessibilityEntropies","accessibilityHierarchies_alpha","accessibilityHierarchies_rsquared","accessibilitySummaries_mean","accessibilitySummaries_median","accessibilitySummaries_sd",
         "closenessEntropies","closenessHierarchies_alpha","closenessHierarchies_rsquared","closenessSummaries_mean","closenessSummaries_median","closenessSummaries_sd",
         "populationEntropies","populationHierarchies_alpha","populationHierarchies_rsquared","populationSummaries_mean","populationSummaries_median","populationSummaries_sd"
)

timedata=data.frame()
for(var in vars){
  melted = melt(currentdata,id.vars=params,measure.vars = paste0(var,samplingTimes),value.name=var)
  if(nrow(timedata)==0){timedata=melted;timedata$time=as.numeric(substring(melted$variable,first=nchar(var)+1))}
  else{timedata[[var]]=melted[[var]]}
}

dir.create(paste0(resdir,'indics'))

for(networkGamma in unique(currentdata$networkGamma)){
    for(networkSpeed in unique(currentdata$networkSpeed)){
      for(var in vars){
      if(length(which(timedata$networkGamma==networkGamma&timedata&timedata$networkSpeed==networkSpeed))>0){
        g=ggplot(timedata[timedata$networkGamma==networkGamma&timedata$networkSpeed==networkSpeed,],
                 aes_string(x="time",y=var,color="networkThreshold",group="networkThreshold")
        )
        g+geom_point(pch='.')+stat_smooth(n=10)+facet_grid(gravityGamma~gravityDecay)+ggtitle(paste0("networkGamma=",networkGamma," ; networkSpeed=",networkSpeed))+stdtheme
        ggsave(paste0(resdir,'indics/',var,'_networkGamma',networkGamma,'_networkSpeed',networkSpeed,'.pdf'),width=30,height=20,units='cm')
      }
    }
  }
}




##################
##################

# lagged correlations

lagdata=data.frame()
for(couple in c("ClosenessAccessibility","PopAccessibility","PopCloseness")){
  melted = melt(currentdata,id.vars=params,measure.vars = paste0("rho",couple,"_tau",lags),value.name="rho")
  melted$tau = as.numeric(substring(melted$variable,first=8+nchar(couple)))
  melted$var = rep(couple,nrow(melted))
  lagdata=rbind(lagdata,melted)
}



dir.create(paste0(resdir,'laggedcorrs'))

for(networkGamma in unique(currentdata$networkGamma)){
  for(networkThreshold in unique(currentdata$networkThreshold)){
    for(networkSpeed in unique(currentdata$networkSpeed)){
      if(length(which(lagdata$networkGamma==networkGamma&lagdata$networkThreshold==networkThreshold&lagdata$networkSpeed==networkSpeed))>0){
      g=ggplot(lagdata[lagdata$networkGamma==networkGamma&lagdata$networkThreshold==networkThreshold&lagdata$networkSpeed==networkSpeed,],
             aes(x=tau,y=rho,color=var,group=var)
      )
      g+geom_point(pch='.')+stat_smooth(span = 0.1)+facet_grid(gravityGamma~gravityDecay)+ggtitle(paste0("networkGamma=",networkGamma," ; networkThreshold=",networkThreshold," ; networkSpeed=",networkSpeed))+stdtheme
      ggsave(paste0(resdir,'laggedcorrs/laggedcorrs_networkGamma',networkGamma,'_networkThreshold',networkThreshold,'_networkSpeed',networkSpeed,'.pdf'),width=30,height=20,units='cm')
      }
    }
  }
}


##############
##############

# distance correlations

distdata=data.frame()
for(couple in c("ClosenessAccessibility","PopAccessibility","PopCloseness")){
  melted = melt(currentdata,id.vars=params,measure.vars = paste0("rhoDist",couple,distcorrbins),value.name="rho")
  melted$dbin = as.numeric(substring(melted$variable,first=8+nchar(couple)))
  melted$var = rep(couple,nrow(melted))
  distdata=rbind(distdata,melted)
}

dir.create(paste0(resdir,'distcorrs'))

for(networkGamma in unique(currentdata$networkGamma)){
  for(networkThreshold in unique(currentdata$networkThreshold)){
    for(networkSpeed in unique(currentdata$networkSpeed)){
      if(length(which(distdata$networkGamma==networkGamma&distdata$networkThreshold==networkThreshold&distdata$networkSpeed==networkSpeed))>0){
        g=ggplot(distdata[distdata$networkGamma==networkGamma&distdata$networkThreshold==networkThreshold&distdata$networkSpeed==networkSpeed,],
                 aes(x=dbin,y=rho,color=var,group=var)
        )
        g+geom_point(pch='.')+stat_smooth(n=10)+facet_grid(gravityGamma~gravityDecay)+ggtitle(paste0("networkGamma=",networkGamma," ; networkThreshold=",networkThreshold," ; networkSpeed=",networkSpeed))+stdtheme
        ggsave(paste0(resdir,'distcorrs/distcorrs_networkGamma',networkGamma,'_networkThreshold',networkThreshold,'_networkSpeed',networkSpeed,'.pdf'),width=30,height=20,units='cm')
      }
    }
  }
}









