
# calib profiles

setwd(paste0(Sys.getenv("CN_HOME"),'/Results/NetworkNecessity/InteractionGibrat/profile/test/test'))


periods=c("1881-1901","1962-1982")
params=c("feedbackDecay","gravityDecay")
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

multiplot(plotlist=plots,cols=1)
