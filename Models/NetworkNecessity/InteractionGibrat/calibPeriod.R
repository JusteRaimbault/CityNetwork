
# results of calibration by period for InteractionGibrat model

setwd(paste0(Sys.getenv('CN_HOME'),'/Results/NetworkNecessity/InteractionGibrat/calibration/period/calibration_20160531-3_grid'))

periods = c("1831-1851","1841-1861","1851-1872","1881-1901","1891-1911","1921-1936","1946-1968","1962-1982","1975-1990")

bests=data.frame()
for(p in periods){
  resfiles = list.files(p)
  # find latest resfile
  generations = as.numeric(gsub(".csv","",substring(resfiles,11)))
  res = read.csv(file = paste0(p,"/",resfiles[generations==max(generations)])) 
  best=res[res$logmse==min(res$logmse),][1,];best$period=p
  bests = rbind(bests,best)
}

# first observations : 
#   - many parameters at bound, relax these
#   - instability : due to single objective ? launch with two objs ?

#  -> add qualitative obj such as hierarchy ? (slope)

plot(as.numeric(substr(bests$period,1,4)),bests$logmse,type='l')


