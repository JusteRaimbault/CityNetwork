
# results of calibration by period for InteractionGibrat model

setwd(paste0(Sys.getenv('CN_HOME'),'/Results/NetworkNecessity/InteractionGibrat/calibration/period/fullmodel/20160531-biobj-1_grid/'))

library(ggplot2)

run='data/calibration_20160531-biobj-1_grid/'

periods = c("1831-1851","1841-1861","1851-1872","1881-1901","1891-1911","1921-1936","1946-1968","1962-1982","1975-1990")

res=list()
for(p in periods){
  resfiles = list.files(paste0(run,p))
  # find latest resfile
  generations = as.numeric(gsub(".csv","",substring(resfiles,11)))
  res[[p]] = read.csv(file = paste0(run,p,"/",resfiles[generations==max(generations)])) 
}

## single obj

bests=data.frame()
for(p in periods){
  r=res[[p]]
  best=r[r$logmse==min(r$logmse),][1,];best$period=p
  bests = rbind(bests,best)
}

# first observations : 
#   - many parameters at bound, relax these
#   - instability : due to single objective ? launch with two objs ?

#  -> add qualitative obj such as hierarchy ? (slope)

plot(as.numeric(substr(bests$period,1,4)),bests$logmse,type='l')


## bi obj

resdir = './'

plots=list()
for(param in c("growthRate","gravityWeight","gravityGamma","gravityDecay","feedbackWeight","feedbackGamma","feedbackDecay")){
d = data.frame()
for(p in periods){
  r=res[[p]];r$period=rep(p,nrow(r))
  d=rbind(d,r)
}
g = ggplot(d)
plots[[param]]=g+geom_point(aes_string(x="logmse",y="mselog",colour=param))+facet_wrap(~period,scales = "free")+scale_colour_gradient(low = "yellow",high="red")+ggtitle(param)
}
multiplot(plotlist = plots,cols=3)
#ggsave(file=paste0(resdir,'allperiods_',param,'.pdf'),width = 15,height=10)






