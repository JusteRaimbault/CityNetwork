
# calib profiles

setwd(paste0(Sys.getenv("CN_HOME"),'/Results/NetworkNecessity/InteractionGibrat/profile/nofeedback/20160607_logmse/data'))


periods=c("1831-1851","1841-1861","1851-1872","1881-1901","1962-1982")
params=c("growthRate","gravityWeight","gravityGamma","gravityDecay")
lastgen=100

plots=list()
for(param in params){
  d=data.frame()
  for(p in periods){
    dd=read.csv(paste0(p,'/',param,'/population',lastgen,'.csv'))
    d=rbind(d,cbind(dd,period=rep(p,nrow(dd))))
  }
  g=ggplot(d,aes_string(x=param,y="logmse"))
  plots[[param]]=g+geom_line()+facet_wrap(~period,scales = "free")
}

multiplot(plotlist=plots,cols=2)
