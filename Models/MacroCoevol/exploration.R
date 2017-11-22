

library(dplyr)
library(ggplot2)
library(reshape2)

source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

setwd(paste0(Sys.getenv('CN_HOME'),'/Results/MacroCoevol/Exploration'))

res <- as.tbl(read.csv('20170926_GRID_VIRTUAL/data/20170926_102630_GRID_VIRTUAL.csv',stringsAsFactors = FALSE,header=F,skip = 1))
resdir='20170926_GRID_VIRTUAL/';


finalTime = 30
samplingStep = 5
samplingTimes = seq(from=0,to=finalTime,by=samplingStep)
taumax = 6
lags = seq(from=-taumax,to=taumax,by=1)
distcorrbins = 1:10

timelyNames<-function(arraynames,samplingTimes){res=c();for(t in samplingTimes){res=append(res,paste0(arraynames,t))};return(res)}

#accessibilityEntropies,accessibilityHierarchies,accessibilitySummaries,closenessEntropies,
# closenessHierarchies,closenessSummaries,complexityAccessibility,complexityCloseness,complexityPop,
# diversityAccessibility,diversityCloseness,diversityPop,feedbackDecay,feedbackGamma,feedbackWeight,
# finalTime,gravityDecay,gravityGamma,gravityWeight,id,nwGmax,nwThreshold,populationEntropies,
# populationHierarchies,populationSummaries,rankCorrAccessibility,rankCorrCloseness,rankCorrPop,
# replication,rhoClosenessAccessibility,rhoDistClosenessAccessibility,rhoDistPopAccessibility,
#rhoDistPopCloseness,rhoPopAccessibility,rhoPopCloseness,synthRankSize

names(res)<-c(
  timelyNames(c("accessibilityEntropies"),samplingTimes),
  timelyNames(c("accessibilityHierarchies_alpha","accessibilityHierarchies_rsquared"),samplingTimes),
  timelyNames(c("accessibilitySummaries_mean","accessibilitySummaries_median","accessibilitySummaries_sd"),samplingTimes),
  timelyNames(c("closenessEntropies"),samplingTimes),
  timelyNames(c("closenessHierarchies_alpha","closenessHierarchies_rsquared"),samplingTimes),
  timelyNames(c("closenessSummaries_mean","closenessSummaries_median","closenessSummaries_sd"),samplingTimes),
  "complexityAccessibility","complexityCloseness","complexityPop","diversityAccessibility","diversityCloseness","diversityPop",
  "feedbackDecay","feedbackGamma","feedbackWeight","finalTime","gravityDecay","gravityGamma","gravityWeight","id","nwGmax","nwThreshold",
  timelyNames(c("populationEntropies"),samplingTimes),
  timelyNames(c("populationHierarchies_alpha","populationHierarchies_rsquared"),samplingTimes),
  timelyNames(c("populationSummaries_mean","populationSummaries_median","populationSummaries_sd"),samplingTimes),
  "rankCorrAccessibility","rankCorrCloseness","rankCorrPop","replication",
  paste0("rhoClosenessAccessibility_tau",lags),
  paste0("rhoDistClosenessAccessibility",distcorrbins),
  paste0("rhoDistPopAccessibility",distcorrbins),
  paste0("rhoDistPopCloseness",distcorrbins),
  paste0("rhoPopAccessibility_tau",lags),
  paste0("rhoPopCloseness_tau",lags),
  "synthRankSize"
)

#params = c("synthRankSize","feedbackDecay","feedbackGamma","feedbackWeight","gravityDecay","gravityGamma","gravityWeight","nwGmax","nwThreshold")
params = c("synthRankSize","gravityDecay","gravityGamma","gravityWeight","nwGmax","nwThreshold")




#
sres = res%>%group_by(id)%>%summarise(count=n())
summary(sres$count)
np=1;for(param in params){np=np*length(unlist(unique(res[,param])))}
#np*50 : ok misses 30 runs only.

##
# evolution of hierarchy in time
vars = c("accessibilityEntropies","accessibilityHierarchies_alpha","accessibilityHierarchies_rsquared","accessibilitySummaries_mean","accessibilitySummaries_median","accessibilitySummaries_sd",
         "closenessEntropies","closenessHierarchies_alpha","closenessHierarchies_rsquared","closenessSummaries_mean","closenessSummaries_median","closenessSummaries_sd",
         "populationEntropies","populationHierarchies_alpha","populationHierarchies_rsquared","populationSummaries_mean","populationSummaries_median","populationSummaries_sd"
         )

timedata=data.frame()
for(var in vars){
  melted = melt(res,id.vars=params,measure.vars = paste0(var,samplingTimes),value.name=var)
  if(nrow(timedata)==0){timedata=melted;timedata$time=as.numeric(substring(melted$variable,first=nchar(var)+1))}
  else{timedata[[var]]=melted[[var]]}
}


nwGmax=0.05
#nwGmax=0.0
# synthRankSize=1.5

dir.create(paste0(resdir,'indics'))

for(synthRankSize in unique(res$synthRankSize)){
for(gravityWeight in unique(res$gravityWeight)){
  for(var in vars){
    g=ggplot(timedata[timedata$synthRankSize==synthRankSize&timedata$nwGmax==nwGmax&timedata$gravityWeight==gravityWeight,],
             aes_string(x="time",y=var,color="nwThreshold",group="nwThreshold")
             )
    g+geom_point()+geom_smooth()+facet_grid(gravityGamma~gravityDecay)+ggtitle(paste0("gravityWeight=",gravityWeight," ; synthRankSize=",synthRankSize))+stdtheme
    #ggsave(paste0(resdir,'indics/no-nw_',var,'_gravityWeight',gravityWeight,'.pdf'),width=30,height=20,units='cm')
    ggsave(paste0(resdir,'indics/',var,'synthRankSize',synthRankSize,'_gravityWeight',gravityWeight,'.pdf'),width=30,height=20,units='cm')
   } 
}
}

#####
# targeted plots

dir.create(paste0(resdir,'targeted'))

# closeness mean
nwGmax=0.05;synthRankSize=1.0;gravityDecay=10;gravityWeight=0.001
var="closenessSummaries_mean"
g=ggplot(timedata[timedata$gravityGamma!=1.0&timedata$synthRankSize==synthRankSize&timedata$nwGmax==nwGmax&timedata$gravityWeight==gravityWeight&timedata$gravityDecay==gravityDecay,],
         aes_string(x="time",y=var,color="nwThreshold",group="nwThreshold")
)
g+geom_point()+geom_smooth()+facet_wrap(~gravityGamma)+
  ggtitle(bquote(w[G]*"="*.(gravityWeight)*" ; "*d[G]*"="*.(gravityDecay)*" ; "*alpha[S]*"="*.(synthRankSize)))+
  xlab(expression(t))+ylab(expression(bar(c[i])(t)))+scale_color_continuous(name=expression(phi[0]))+
  stdtheme
ggsave(paste0(resdir,'targeted/',var,'_synthRankSize',synthRankSize,'_gravityWeight',gravityWeight,"_gravityDecay",gravityDecay,'.png'),width=20,height=14,units='cm')


nwGmax=0.05;synthRankSize=1.0;gravityGamma=0.5;gravityWeight=0.001;gravityDecays=c(10,110)
var="populationEntropies"
g=ggplot(timedata[timedata$gravityDecay%in%gravityDecays&timedata$gravityGamma==gravityGamma&timedata$synthRankSize==synthRankSize&timedata$nwGmax==nwGmax&timedata$gravityWeight==gravityWeight,],
         aes_string(x="time",y=var,color="nwThreshold",group="nwThreshold")
)
g+geom_point()+geom_smooth()+facet_wrap(~gravityDecays)+
  ggtitle(bquote(w[G]*"="*.(gravityWeight)*" ; "*gamma[G]*"="*.(gravityGamma)*" ; "*alpha[S]*"="*.(synthRankSize)))+
  xlab(expression(t))+ylab(expression(epsilon*"["*P[i]*"]"*(t)))+scale_color_continuous(name=expression(phi[0]))+
  stdtheme
ggsave(paste0(resdir,'targeted/',var,'_synthRankSize',synthRankSize,'_gravityWeight',gravityWeight,"_gravityGamma",gravityGamma,'.png'),width=20,height=14,units='cm')





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
g+geom_point(pch='.')+geom_smooth()+facet_grid(gravityGamma~gravityDecay)+ggtitle(paste0("gravityWeight=",gravityWeight," ; nwThreshold=",nwThreshold))+stdtheme
ggsave(paste0(resdir,'laggedcorrs/laggedcorrs_gravityWeight',gravityWeight,'_nwThreshold',nwThreshold,'.pdf'),width=30,height=20,units='cm')

  }
}


# stat test
synthRankSize=1.5;nwGmax=0.05
gravityWeight=5e-04;nwThreshold=4.5
gravityGamma=1.5;gravityDecay=110
g=ggplot(lagdata[lagdata$synthRankSize==synthRankSize&lagdata$nwGmax==nwGmax&lagdata$gravityWeight==gravityWeight&lagdata$nwThreshold==nwThreshold&lagdata$gravityGamma==gravityGamma&lagdata$gravityDecay==gravityDecay,],
         aes(x=tau,y=rho,color=var,group=var)
         )
g+geom_point(pch='.')+geom_smooth()

g=ggplot(lagdata[lagdata$synthRankSize==synthRankSize&lagdata$nwGmax==nwGmax&lagdata$gravityWeight==gravityWeight&lagdata$nwThreshold==nwThreshold&lagdata$gravityGamma==gravityGamma&lagdata$gravityDecay==gravityDecay,],
         aes(x=rho,color=tau,group=tau)
)
g+geom_density()+facet_wrap(~var)

# compare distributions -> two sample ks test
var="PopAccessibility"
cdata = lagdata[lagdata$synthRankSize==synthRankSize&lagdata$nwGmax==nwGmax&lagdata$gravityWeight==gravityWeight&
          lagdata$nwThreshold==nwThreshold&lagdata$gravityGamma==gravityGamma&lagdata$gravityDecay==gravityDecay&
          lagdata$var==var,]
test=ks.test(cdata$rho[cdata$tau==0],cdata$rho[cdata$tau==2])
sdata=cdata%>%group_by(tau)%>%summarise(rho=mean(rho))
taumax = sdata$tau[sdata$rho==max(sdata$rho[sdata$tau>0])]
taumin = sdata$tau[sdata$rho==max(sdata$rho[sdata$tau<0])]
ks.test(cdata$rho[cdata$tau==0],cdata$rho[cdata$tau==taumax])
ks.test(cdata$rho[cdata$tau==0],cdata$rho[cdata$tau==taumin])
for(tau in c(-6:-1,1:6)){show(ks.test(cdata$rho[cdata$tau==0],cdata$rho[cdata$tau==tau])$p.value)}



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
    g+geom_point()+geom_smooth()+facet_grid(gravityGamma~gravityDecay)+ggtitle(paste0("gravityWeight=",gravityWeight," ; nwThreshold=",nwThreshold))+stdtheme
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
    #if(!(var=="Pop"&mes=="complexity")){
    show(paste0(mes,var))
      g=ggplot(res[res$synthRankSize==synthrankSize&res$nwGmax==nwGmax,],aes_string(x="gravityDecay",y=paste0(mes,var),color="gravityGamma",group="gravityGamma"))
      g+geom_point()+geom_smooth()+facet_grid(gravityWeight~nwThreshold,scales="free")+ggtitle(paste0("synthrankSize=",synthrankSize," ; nwGmax=",nwGmax))#+stdtheme
      ggsave(paste0(resdir,'complexity/',mes,var,'_synthrankSize',synthrankSize,'_nwGmax',nwGmax,'.pdf'),width=30,height=20,units='cm')
    #}
  }
}

}}


#synthrankSize = 1.5
#gravityWeight=0.00075

#g=ggplot(res[res$synthRankSize==synthrankSize&res$gravityWeight==gravityWeight,],aes_string(x="gravityDecay",y="diversityPop",color="gravityGamma",group="gravityGamma"))
#g+geom_point()+geom_smooth()+facet_grid(nwThreshold~nwGmax,scales="free")
#ggsave(paste0(resdir,'complexity/',mes,var,'_synthrankSize',synthrankSize,'_nwGmax',nwGmax,'.pdf'),width=30,height=20,units='cm')

# -> difficult to see an effect











