

library(dplyr)
library(ggplot2)
library(reshape2)

setwd(paste0(Sys.getenv('CN_HOME'),'/Results/MacroCoevol/Exploration'))

res <- as.tbl(read.csv('20170613_virtual/data/20170613_164244_grid_virtual_local.csv',stringsAsFactors = FALSE,header=F,skip = 1))

finalTime = 30
samplingStep = 5
samplingTimes = seq(from=0,to=finalTime,by=samplingStep)
taumax = 6
lags = seq(from=-taumax,to=taumax,by=1)
distcorrbins = 1:10

names(res)<-c(
  paste0("accessibilityEntropies",samplingTimes),paste0("accessibilityHierarchies_alpha",samplingTimes),paste0("accessibilityHierarchies_rsquared",samplingTimes),paste0("accessibilitySummaries_mean",samplingTimes),paste0("accessibilitySummaries_median",samplingTimes),paste0("accessibilitySummaries_sd",samplingTimes),
  paste0("closenessEntropies",samplingTimes),paste0("closenessHierarchies_alpha",samplingTimes),paste0("closenessHierarchies_rsquared",samplingTimes),paste0("closenessSummaries_mean",samplingTimes),paste0("closenessSummaries_median",samplingTimes),paste0("closenessSummaries_sd",samplingTimes),
  "complexityAccessibility","complexityCloseness","diversityAccessibility","diversityCloseness","diversityPop",
  "feedbackDecay","feedbackGamma","feedbackWeight","finalTime","gravityDecay","gravityGamma","gravityWeight","id","nwGmax","nwThreshold",
  paste0("populationEntropies",samplingTimes),paste0("populationHierarchies_alpha",samplingTimes),paste0("populationHierarchies_rsquared",samplingTimes),paste0("populationSummaries_mean",samplingTimes),paste0("populationSummaries_median",samplingTimes),paste0("populationSummaries_sd",samplingTimes),
  "rankCorrAccessibility","rankCorrCloseness","rankCorrPop","replication",
  paste0("rhoClosenessAccessibility_tau",lags),
  paste0("rhoDistClosenessAccessibility",distcorrbins),paste0("rhoDistPopAccessibility",distcorrbins),paste0("rhoDistPopCloseness",distcorrbins),
  paste0("rhoPopAccessibility_tau",lags),paste0("rhoPopCloseness_tau",lags),
  "synthRankSize"
)

#params = c("synthRankSize","feedbackDecay","feedbackGamma","feedbackWeight","gravityDecay","gravityGamma","gravityWeight","nwGmax","nwThreshold")
params = c("synthRankSize","gravityDecay","gravityGamma","gravityWeight","nwGmax","nwThreshold")

resdir='20170613_virtual/'

#
#data.frame(res%>%group_by(id)%>%summarise(count=n()))



##
# evolution of hierarchy in time
vars = c("accessibilityEntropies","accessibilityHierarchies_alpha","accessibilityHierarchies_rsquared","accessibilitySummaries_mean","accessibilitySummaries_median","accessibilitySummaries_sd",
         "closenessEntropies","closenessHierarchies_alpha","closenessHierarchies_rsquared","closenessSummaries_mean","closenessSummaries_median","closenessSummaries_mean",
         "populationEntropies","populationHierarchies_alpha","populationHierarchies_rsquared","populationSummaries_mean","populationSummaries_median","populationSummaries_sd"
         )

timedata=data.frame()
for(var in vars){
  melted = melt(res,id.vars=params,measure.vars = paste0(var,samplingTimes),value.name=var)
  if(nrow(timedata)==0){timedata=melted;timedata$time=as.numeric(substring(melted$variable,first=nchar(var)+1))}
  else{timedata[[var]]=melted[[var]]}
}

synthRankSize=1.5
nwGmax=0.05

dir.create(paste0(resdir,'indics'))

for(gravityWeight in unique(res$gravityWeight)){
  for(var in vars){
    g=ggplot(timedata[timedata$synthRankSize==synthRankSize&timedata$nwGmax==nwGmax&timedata$gravityWeight==gravityWeight,],
             aes_string(x="time",y=var,color="nwThreshold",group="nwThreshold")
             )
    g+geom_point()+geom_smooth()+facet_grid(gravityGamma~gravityDecay)
    ggsave(paste0(resdir,'indics/',var,'_gravityWeight',gravityWeight,'.pdf'),width=30,height=20,units='cm')
  } 
}

##
# lagged correlations
# -> forgot pop-pop in correlations

# need to reshape

lagdata=data.frame()
for(couple in c("ClosenessAccessibility","PopAccessibility","PopCloseness")){
#couple = "ClosenessAccessibility"
melted = melt(res,id.vars=params,measure.vars = paste0("rho",couple,"_tau",lags),value.name="rho")
melted$tau = as.numeric(substring(melted$variable,first=8+nchar(couple)))
melted$var = rep(couple,nrow(melted))
lagdata=rbind(lagdata,melted)
}

synthRankSize=1.5
nwGmax=0.05

dir.create(paste0(resdir,'laggedcorrs'))

for(gravityWeight in unique(res$gravityWeight)){
  for(nwThreshold in unique(res$nwThreshold)){  

#gravityWeight=0.00075
#nwThreshold=2.5

g=ggplot(lagdata[lagdata$synthRankSize==synthRankSize&lagdata$nwGmax==nwGmax&lagdata$gravityWeight==gravityWeight&lagdata$nwThreshold==nwThreshold,],
         aes(x=tau,y=rho,color=var,group=var)
         )
g+geom_point(pch='.')+geom_smooth()+facet_grid(gravityGamma~gravityDecay)
ggsave(paste0(resdir,'laggedcorrs/laggedcorrs_gravityWeight',gravityWeight,'_nwThreshold',nwThreshold,'.pdf'),width=30,height=20,units='cm')

  }
}



##
# rho = f(d)

distdata=data.frame()
for(couple in c("ClosenessAccessibility","PopAccessibility","PopCloseness")){
  melted = melt(res,id.vars=params,measure.vars = paste0("rhoDist",couple,distcorrbins),value.name="rho")
  melted$dbin = as.numeric(substring(melted$variable,first=8+nchar(couple)))
  melted$var = rep(couple,nrow(melted))
  distdata=rbind(distdata,melted)
}

synthRankSize=1.5
nwGmax=0.05

dir.create(paste0(resdir,'distcorrs'))

for(gravityWeight in unique(res$gravityWeight)){
  for(nwThreshold in unique(res$nwThreshold)){  
    g=ggplot(distdata[distdata$synthRankSize==synthRankSize&distdata$nwGmax==nwGmax&distdata$gravityWeight==gravityWeight&distdata$nwThreshold==nwThreshold,],
             aes(x=dbin,y=rho,color=var,group=var)
    )
    g+geom_point()+geom_smooth()+facet_grid(gravityGamma~gravityDecay)
    ggsave(paste0(resdir,'distcorrs/distcorrs_gravityWeight',gravityWeight,'_nwThreshold',nwThreshold,'.pdf'),width=30,height=20,units='cm')
    
  }
}






##
# complexity, diversity and rankcorrelations
dir.create(paste0(resdir,'complexity'))

for(synthrankSize in unique(res$synthRankSize)){
  for(nwGmax in unique(res$nwGmax)){
#synthrankSize = 1.0
#nwGmax = 0.0

vars = c("Accessibility","Closeness","Pop")
measures = c("complexity","diversity","rankCorr")

for(var in vars){
  for(mes in measures){
    if(!(var=="Pop"&mes=="complexity")){show(paste0(mes,var))
      g=ggplot(res[res$synthRankSize==synthrankSize&res$nwGmax==nwGmax,],aes_string(x="gravityDecay",y=paste0(mes,var),color="gravityGamma",group="gravityGamma"))
      g+geom_point()+geom_smooth()+facet_grid(gravityWeight~nwThreshold,scales="free")
      ggsave(paste0(resdir,'complexity/',mes,var,'_synthrankSize',synthrankSize,'_nwGmax',nwGmax,'.pdf'),width=30,height=20,units='cm')
    }
  }
}

}}






