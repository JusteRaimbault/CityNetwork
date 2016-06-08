
# analysis of exploration results

library(dplyr)
library(ggplot2)

setwd(paste0(Sys.getenv('CN_HOME'),'/Results/NetworkNecessity/InteractionGibrat/explo/nofeedback/20160608-4_allperiods_grid_local'))

res <- as.tbl(read.csv('data/2016_06_08_18_53_23_LHS_GRID_LOCAL.csv'))

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
res$rate=res$gravityWeight/res$growthRate
p1="rate";p2="gravityDecay";p3="gravityGamma";p4="growthRate";err="mselog"
g=ggplot(res)
g+geom_line(aes_string(x=p1,y=err,colour=p2,group=p2))+facet_grid(paste0(p3,"~",p4),scales="free")#)))+stat_smooth()#+facet_wrap(~gravityGamma,scales = "free")



