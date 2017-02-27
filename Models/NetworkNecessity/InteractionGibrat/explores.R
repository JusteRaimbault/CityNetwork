
# analysis of exploration results

library(dplyr)
library(ggplot2)
source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

#setwd(paste0(Sys.getenv('CN_HOME'),'/Results/NetworkNecessity/InteractionGibrat/calibration/all/fixedgravity/20160920_fixedgravity_local'))
#setwd(paste0(Sys.getenv('CN_HOME'),'/Results/NetworkNecessity/InteractionGibrat/exploration/full/20160912_gridfull/data'))
#setwd(paste0(Sys.getenv('CN_HOME'),'/Results/NetworkNecessity/InteractionGibrat/calibration/period/nofeedback/20170220_test'))
#setwd(paste0(Sys.getenv('CN_HOME'),'/Results/NetworkNecessity/InteractionGibrat/exploration/nofeedback/20170218_1831-1851'))
setwd(paste0(Sys.getenv('CN_HOME'),'/Models/NetworkNecessity/InteractionGibrat/calibration'))



res <- as.tbl(read.csv('20170224_calibperiod_nsga/1841-1861/population100.csv'))
#res <- as.tbl(read.csv('data/2017_02_18_20_25_12_CALIBGRAVITY_GRID.csv'))

for(period in c("1831-1851","1841-1861","1851-1872","1881-1901")){
  res <- as.tbl(read.csv(paste0('20170224_calibperiod_nsga/',period,'/population100.csv')))
  show(mean(res$gravityDecay))
  show(sd(res$gravityDecay))
}



#
#m = lm(logmse~gravityDecay+gravityGamma+gravityWeight+growthRate,res)
# 
# d <- res %>% mutate(gfg=floor(feedbackGamma*6)/6,ggd=floor(gravityDecay/100)*100)
# res%>%group_by(growthRate)%>%summarise(logmse=mean(logmse))
#d=res[which(res$gravityDecay<50),]
d=res[res$logmse<24.5&res$mselog<6.5&res$gravityDecay<50,]
gp = ggplot(d,aes(x=gravityDecay,y=logmse,colour=gravityWeight,group=gravityWeight))
gp+geom_line()+facet_grid(growthRate~gravityGamma,scales="free")#+stat_smooth()


######
params = c("growthRate","gravityWeight","gravityGamma","gravityDecay")#"growthRate","gravityWeight")
#params = c("growthRate","gravityWeight","gravityGamma","gravityDecay","feedbackWeight","feedbackGamma","feedbackDecay")
#params = c("feedbackWeight","feedbackGamma","feedbackDecay")
d=res#[res$logmse<24.5&res$mselog<6.35,]
plots=list()
for(param in params){
  g=ggplot(d,aes_string(x="logmse",y="mselog",colour=param))
  plots[[param]]=g+geom_point()+scale_colour_gradient(low="yellow",high="red")
}
multiplot(plotlist = plots,cols=2)







#######
##M1
#data.frame(res[res$logmse<31.24&res$mselog<302.8125,])
##M2
#data.frame(res[res$logmse<31.24&res$mselog<303,])

####
#res$rate=res$gravityWeight/res$growthRate
#p1="rate";p2="gravityDecay";p3="gravityGamma";p4="growthRate";err="mselog"
res$rate=res$feedbackWeight/res$growthRate
p1="rate";p2="feedbackDecay";p3="feedbackGamma";p4="growthRate";err="logmse"
g=ggplot(res)#[abs(res$growthRate-0.071)<0.0001,])#res[res$growthRate==0.07|res$growthRate==0.06,])
g+geom_line(aes_string(x=p1,y=err,colour=p2,group=p2),alpha=0.7)#+facet_grid(paste0(p3,"~",p4),scales="free")#)))+stat_smooth()#+facet_wrap(~gravityGamma,scales = "free")






####
# Determination of range of min growth rates

minlogmse = c();minmselog=c()
for(gravityWeight in unique(res$gravityWeight)){
  for(gravityGamma in unique(res$gravityGamma)){
    for(gravityDecay in unique(res$gravityDecay)){
      d = res[res$gravityWeight==gravityWeight&res$gravityGamma==gravityGamma&res$gravityDecay==gravityDecay,]
      minlogmse = append(minlogmse,d$growthRate[d$logmse==min(d$logmse)])
      minmselog = append(minmselog,d$growthRate[d$mselog==min(d$mselog)])
    }
  }
}

#
# -> range(minlogmse) ; range(minmselog)
#
data.frame(res[res$logmse==min(res$logmse),])
data.frame(res[res$mselog==min(res$mselog),])




############
# Looking only at gravity

resgrav = res[res$feedbackWeight==0.0&res$feedbackDecay==2.0&res$feedbackGamma==1.5,]
#rm(res)

sres = resgrav %>% group_by(gravityGamma,gravityWeight,growthRate) %>% summarise(gravminlogmse=gravityDecay[which(logmse==min(logmse))[1]],gravminmselog=gravityDecay[which(mselog==min(mselog))[1]])

g=ggplot(sres)
g+geom_point(aes(x=gravityWeight/growthRate,y=gravminlogmse,colour=gravityGamma))
# -> needs more exploration
sres[sres$gravminlogmse==201,]
ressample=sres
ressample=resgrav[resgrav$gravityGamma==1&abs(resgrav$gravityWeight-6e-04)<1e-10&resgrav$growthRate==0.007,]
plot(ressample$gravityDecay,ressample$logmse,type='l')





