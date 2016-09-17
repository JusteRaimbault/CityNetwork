
# analysis of exploration results

library(dplyr)
library(ggplot2)
source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

setwd(paste0(Sys.getenv('CN_HOME'),'/Results/NetworkNecessity/InteractionGibrat/calibration/all/fullmodel/20160917_fullmodel_local'))

res <- as.tbl(read.csv('population30.csv'))

#
#m = lm(logmse~gravityDecay+gravityGamma+gravityWeight+growthRate,res)
# 
# d <- res %>% mutate(gfg=floor(feedbackGamma*6)/6,ggd=floor(gravityDecay/100)*100)
# res%>%group_by(growthRate)%>%summarise(logmse=mean(logmse))
d=res#[which(res$growthRate==0.007),]
gp = ggplot(d,aes(x=growthRate,y=mselog,colour=gravityGamma,group=gravityGamma))
gp+geom_line()+facet_grid(gravityWeight~gravityDecay,scales="free")#+stat_smooth()


######
#params = c("growthRate","gravityWeight","gravityGamma","gravityDecay")#"growthRate","gravityWeight")
params = c("growthRate","gravityWeight","gravityGamma","gravityDecay","feedbackWeight","feedbackGamma","feedbackDecay")
d=res#[res$logmse<35&res$mselog<400,]
plots=list()
for(param in params){
  g=ggplot(d,aes_string(x="logmse",y="mselog",colour=param))
  plots[[param]]=g+geom_point()+scale_colour_gradient(low="yellow",high="red")
}
multiplot(plotlist = plots,cols=4)

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





