
library(dplyr)
library(ggplot2)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/Reproduction/SimpopNet'))

res <- as.tbl(read.csv('exploration/20170922_221442_GRIDLHS.csv',stringsAsFactors = FALSE,header=F,skip = 1))
resdir <- paste0(Sys.getenv('CN_HOME'),'/Results/Reproduction/SimpopNet/20170922_GRIDLHS');dir.create(resdir)

finalTime = 100
samplingStep = 5
samplingTimes = seq(from=0,to=finalTime-samplingStep,by=samplingStep)
taumax = 6
lags = seq(from=-taumax,to=taumax,by=1)
distcorrbins = 1:10

timelyNames<-function(arraynames,samplingTimes){res=c();for(t in samplingTimes){res=append(res,paste0(arraynames,t))};return(res)}


#accessibilityEntropies,accessibilityHierarchies,accessibilitySummaries,closenessEntropies,closenessHierarchies,
#closenessSummaries,complexityAccessibility,complexityCloseness,complexityPop,confid,diversityAccessibility,
#diversityCloseness,diversityPop,finalTime,gravityDecay,gravityGamma,id,networkGamma,networkSpeed,
#networkThreshold,nwDiameter,nwHierarchyBwCentrality,nwLength,nwMeanBwCentrality,nwMeanPathLength,
#nwRelativeSpeed,populationEntropies,populationHierarchies,populationSummaries,rankCorrAccessibility,
#rankCorrCloseness,rankCorrPop,replication,rhoClosenessAccessibility,rhoDistClosenessAccessibility,
#rhoDistPopAccessibility,rhoDistPopCloseness,rhoPopAccessibility,rhoPopCloseness,synthCities,synthMaxDegree,
#synthRankSize,synthShortcut,synthShortcutNum

names(res)<-c(
  timelyNames(c("accessibilityEntropies"),samplingTimes),
  timelyNames(c("accessibilityHierarchies_alpha","accessibilityHierarchies_rsquared"),samplingTimes),
  timelyNames(c("accessibilitySummaries_mean","accessibilitySummaries_median","accessibilitySummaries_sd"),samplingTimes),
  timelyNames(c("closenessEntropies"),samplingTimes),
  timelyNames(c("closenessHierarchies_alpha","closenessHierarchies_rsquared"),samplingTimes),
  timelyNames(c("closenessSummaries_mean","closenessSummaries_median","closenessSummaries_sd"),samplingTimes),
  "complexityAccessibility","complexityCloseness","complexityPop","confid",
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

params = c("gravityDecay","gravityGamma","networkGamma","networkThreshold","networkSpeed","synthRankSize","synthCities","synthShortcut","synthMaxDegree","synthShortcutNum")

vars = c("accessibilityEntropies95","accessibilityHierarchies_alpha95","accessibilitySummaries_mean95",
         "closenessEntropies95","closenessHierarchies_alpha95","closenessSummaries_mean95",
         "complexityAccessibility","complexityCloseness","complexityPop","diversityAccessibility","diversityCloseness",
         "diversityPop"
         )

sres = res %>% group_by(synthCities,synthMaxDegree,synthRankSize,synthShortcut,synthShortcutNum) %>% summarise(count=n())


########
## 1) Variability

## sharpe repets vs phase diag (average on configs)
##  and repets vs all (eq to phase diag vs configs)

sres=res%>%group_by(id)%>%summarise(count=n(),sdsynthCities=sd(synthCities))
sres=res%>%group_by(id,confid)%>%summarise(count=n())
sres=res%>%group_by(replication)%>%summarise(count=n())



sres = res %>% group_by(synthCities,synthMaxDegree,synthRankSize,synthShortcut,synthShortcutNum,id) %>% summarise(
  count=n(),
  accessibilityEntropies=mean(accessibilityEntropies95)/sd(accessibilityEntropies95)
  )
summary(sres$accessibilityEntropies)

sres = res %>% group_by(synthCities,synthMaxDegree,synthRankSize,synthShortcut,synthShortcutNum) %>% summarise(
  accessibilityEntropies=mean(accessibilityEntropies95)/sd(accessibilityEntropies95),
  count=n()
)
summary(sres$accessibilityEntropies)


sres = res %>% group_by(confid) %>% summarise(
  accessibilityEntropies=mean(accessibilityEntropies95)/sd(accessibilityEntropies95),
  count=n()
)
summary(sres$accessibilityEntropies)


mean(res$accessibilityEntropies95)/sd(res$accessibilityEntropies95)









