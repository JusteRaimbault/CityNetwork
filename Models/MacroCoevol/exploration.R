

library(dplyr)
library(ggplot2)

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
# -> forgot pop-pop






##
# lagged correlations

# need to reshape










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


##
# rho = f(d)



