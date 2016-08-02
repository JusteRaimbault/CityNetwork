
# results of calibration by period for InteractionGibrat model

#setwd(paste0(Sys.getenv('CN_HOME'),'/Results/NetworkNecessity/InteractionGibrat/calibration/period/nofeedback/calibration_20160607-nofeedback-biobj-1_grid/'))
setwd(paste0(Sys.getenv('CN_HOME'),'/Results/NetworkNecessity/InteractionGibrat'))
setwd('calibration/all/fullmodel/20160609_fullmodel/')


library(ggplot2)

run='data/'

periods = c("1831-1851","1841-1861","1851-1872","1881-1901","1891-1911","1921-1936","1946-1968","1962-1982","1975-1990")

res=list()
for(p in periods){
  resfiles = list.files(paste0(run,p))
  # find latest resfile
  generations = as.numeric(gsub(".csv","",substring(resfiles,11)))
  res[[p]] = read.csv(file = paste0(run,p,"/population",max(generations),'.csv')) 
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


d=read.csv('data/population500.csv')

plots=list()
for(param in c("growthRate","gravityWeight","gravityGamma","gravityDecay","feedbackWeight","feedbackGamma","feedbackDecay")){
  #c("growthRate","gravityWeight","gravityGamma","gravityDecay")){#,
#d = data.frame()
#for(p in periods){
#  r=res[[p]];r$period=rep(p,nrow(r))
#  d=rbind(d,r)
#}
g = ggplot(d)
plots[[param]]=g+geom_point(aes_string(x="logmse",y="mselog",colour=param))+#facet_wrap(~period,scales = "free")+
  scale_colour_gradient(low = "yellow",high="red")+ggtitle(param)
  #scale_colour_gradient2(midpoint=1000)#colours=c("yellow","orange","red"),values=c(0.0,1000,100000))#
}
multiplot(plotlist = plots,cols=4)
#ggsave(file=paste0(resdir,'allperiods_',param,'.pdf'),width = 15,height=10)


###
## cv speed ?
#
# plot sum of obj as a function of time ?
#  or diff in Pareto front localization ?
#

res=data.frame()
for(p in periods){
  diffs=c()
  resfiles = list.files(paste0(run,p))
  generations = sort(as.numeric(gsub(".csv","",substring(resfiles,11))))
  for(gen in 1:100){#length(generations)){
    show(gen)
    curr = read.csv(file = paste0(run,p,"/population",gen,".csv")) 
    #prev = read.csv(file = paste0(run,p,"/population",(gen-1),".csv"))
    diffs=append(diffs,sum(curr$logmse)+sum(curr$mselog))#(sum(curr$logmse)-sum(prev$logmse))^2+(sum(curr$mselog)-sum(prev$mselog))^2)
  }
  res=rbind(res,data.frame(diffs,generation=1:length(diffs),period=rep(p,length(diffs))))
}

g=ggplot(res,aes(x=generation,y=diffs,colour=period))
g+geom_line()




####
## simple calib, one param

setwd(paste0(Sys.getenv('CN_HOME'),'/Results/NetworkNecessity/InteractionGibrat/calibration/period/simple/calibration_20160607-simple/data'))

d=data.frame()
for(p in periods){
  dd=read.csv(paste0(p,'simple.csv'))
  d=rbind(d,cbind(dd,period=rep(p,nrow(dd))))
}

g=ggplot(d,aes(x=growthRate,y=logmse))#,colour=growthRate))
g+geom_line()+facet_wrap(~period,scales = "free")#+scale_colour_gradient(low = "yellow",high="red")






