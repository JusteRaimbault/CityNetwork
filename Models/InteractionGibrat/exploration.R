# analysis of exploration results

library(dplyr)
library(ggplot2)

source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

#setwd(paste0(Sys.getenv('CN_HOME'),'/Results/NetworkNecessity/InteractionGibrat/exploration/fixedgravity/20160609-1_allperiods_gridlocal'))
setwd(paste0(Sys.getenv('CN_HOME'),'/Results/NetworkNecessity/InteractionGibrat/exploration/feedbackonly/20160608-1_allperiods_grid_local'))

#res <- as.tbl(read.csv('data/2016_06_09_12_21_28_LHS_GRID_LOCAL_alpha04.csv'))
res<-as.tbl(read.csv('data/2016_06_08_20_01_49_LHS_GRID_LOCAL.csv'))

#
#m = lm(logmse~gravityDecay+gravityGamma+gravityWeight+growthRate,res)
# 
# d <- res %>% mutate(gfg=floor(feedbackGamma*6)/6,ggd=floor(gravityDecay/100)*100)
# res%>%group_by(growthRate)%>%summarise(logmse=mean(logmse))
d=res#[which(res$growthRate==0.007),]
gp = ggplot(d,aes(x=gravityDecay,y=mselog,colour=gravityGamma))
gp+geom_point()+facet_grid(growthRate~gravityWeight,scales="free_y")#+stat_smooth()


######
params = c("gravityGamma","gravityDecay","gravityAlpha")#"growthRate","gravityWeight")
d=res#[res$logmse<35&res$mselog<400,]
plots=list()
for(param in params){
  g=ggplot(d,aes_string(x="logmse",y="mselog",colour=param))
  plots[[param]]=g+geom_point()+scale_colour_gradient(low="yellow",high="red")
}
multiplot(plotlist = plots,cols=3)

####
#res$rate=res$gravityWeight/res$growthRate
#p1="rate";p2="gravityDecay";p3="gravityGamma";p4="growthRate";err="mselog"
res$rate=res$feedbackWeight/res$growthRate
p1="rate";p2="feedbackDecay";p3="feedbackGamma";p4="growthRate";err="logmse"
g=ggplot(res)#[abs(res$growthRate-0.071)<0.0001,])#res[res$growthRate==0.07|res$growthRate==0.06,])
g+geom_line(aes_string(x=p1,y=err,colour=p2,group=p2),alpha=0.7)#+facet_grid(paste0(p3,"~",p4),scales="free")#)))+stat_smooth()#+facet_wrap(~gravityGamma,scales = "free")


#### logmsezoom
p1="feedbackDecay";p2="rate";p3="feedbackGamma";p4="growthRate";err="logmse"
g=ggplot(res)#[abs(res$growthRate-0.071)<0.0001,])#res[res$growthRate==0.07|res$growthRate==0.06,])
g+geom_line(aes_string(x=p1,y=err,colour=p2,group=p2),alpha=0.7)+xlab(expression(d[N]))+ylab(expression(epsilon[G]))+
  scale_colour_continuous(name=expression(w[N]*'/'*r[0]))+stdtheme#+facet_grid(paste0(p3,"~",p4),scales="free")#)))+stat_smooth()#+facet_wrap(~gravityGamma,scales = "free")
ggsave('logmse-feedbackDecay_ZOOM.png',width=20,height=15,units='cm')

p1="feedbackDecay";p2="rate";p3="feedbackGamma";p4="growthRate";err="mselog"
g=ggplot(res)#[abs(res$growthRate-0.071)<0.0001,])#res[res$growthRate==0.07|res$growthRate==0.06,])
g+geom_line(aes_string(x=p1,y=err,colour=p2,group=p2),alpha=0.7)+xlab(expression(d[N]))+ylab(expression(epsilon[G]))+
  scale_colour_continuous(name=expression(w[N]*'/'*r[0]))+stdtheme#+facet_grid(paste0(p3,"~",p4),scales="free")#)))+stat_smooth()#+facet_wrap(~gravityGamma,scales = "free")
ggsave('logmse-feedbackDecay_ZOOM.png',width=20,height=15,units='cm')


