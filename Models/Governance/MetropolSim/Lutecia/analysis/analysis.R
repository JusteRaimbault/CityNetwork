
library(dplyr)
library(ggplot2)

setwd(paste0(Sys.getenv('CN_HOME'),'/Results/Governance/'))

resdir = '20170508_lhs/'
res <- as.tbl(read.csv(file = '20170508_lhs/data/20170508_190418_lhs.csv',sep=',',header=T))

####
# TODO : 
#   - specific calib on bridges ?
#   - random network null model ?

##
# hist of obj

g=ggplot(res,aes(x=targetDistance,..count..))
g+geom_histogram(bins = 50)#+geom_density(col='red',adjust=2)
ggsave(filename = paste0(resdir,'hist_targetDistance.png'),width = 15,height=10,units = 'cm')


## distance as function of collaboration

g=ggplot(res,aes(x=regionalproba,y=targetDistance,color=realcollab))
g+geom_point()+stat_smooth()
ggsave(filename = paste0(resdir,'regional-distance_colorrealcollab.png'),width = 15,height=10,units = 'cm')

g=ggplot(res[res$targetDistance<140,],aes(x=regionalproba,y=targetDistance,color=realcollab))
g+geom_point()+stat_smooth()
ggsave(filename = paste0(resdir,'regional-distance_colorrealcollab_less140.png'),width = 15,height=10,units = 'cm')


# color by game type ?
g=ggplot(res,aes(x=regionalproba,y=targetDistance,color=gametype))
g+geom_point()+stat_smooth()
ggsave(filename = paste0(resdir,'regional-distance_colorgametype.png'),width = 15,height=10,units = 'cm')


g=ggplot(res,aes(x=gametype,y=targetDistance))
g+geom_violin(draw_quantiles = c(0.25,0.5,0.75))
ggsave(filename = paste0(resdir,'distanceviolin_gametype.png'),width = 15,height=10,units = 'cm')



sres = res%>%group_by(realcollab)%>%summarise(meanTargetDistance=mean(targetDistance),sdTargetDistance=sd(targetDistance))
g=ggplot(res,aes(x=realcollab,y=targetDistance,color=regionalproba))
g+geom_point()+#stat_smooth(n = 10000)
  geom_point(data=sres,aes(x=realcollab,y=meanTargetDistance),col='red')+
  geom_line(data=sres,aes(x=realcollab,y=meanTargetDistance),col='red')+
  geom_errorbar(data=sres,aes(x=realcollab,y=meanTargetDistance,ymin=meanTargetDistance-sdTargetDistance,ymax=meanTargetDistance+sdTargetDistance),col='red')
ggsave(filename = paste0(resdir,'collab-distance_colorregional.png'),width = 15,height=10,units = 'cm')


## does regional proba/ collaboration level increase accessibility ?

g=ggplot(res,aes(x=regionalproba,y=accessibility,color=realcollab))
g+geom_point()+stat_smooth()
# NOTHING !!
ggsave(filename = paste0(resdir,'regional-access_colorrealcollab.png'),width = 15,height=10,units = 'cm')

sres = res%>%group_by(realcollab)%>%summarise(meanAccessibility=mean(accessibility),sdAccessibility=sd(accessibility))
g=ggplot(res,aes(x=realcollab,y=accessibility,color=regionalproba))
g+geom_point()+
  geom_point(data=sres,aes(x=realcollab,y=meanAccessibility),col='red')+geom_line(data=sres,aes(x=realcollab,y=meanAccessibility),col='red')+
  geom_errorbar(data=sres,aes(x=realcollab,y=meanAccessibility,ymin=meanAccessibility-sdAccessibility,ymax=meanAccessibility+sdAccessibility),col='red')



## lambda accessibility
g=ggplot(res,aes(x=lambdaacc,y=targetDistance,color=realcollab))
g+geom_point()+stat_smooth()
ggsave(filename = paste0(resdir,'lambdaacc-distance_colorrealcollab.png'),width = 15,height=10,units = 'cm')

## eucl pace
# (close to 1 should yield random network ?)
#

g=ggplot(res,aes(x=euclpace,y=targetDistance,color=realcollab))
g+geom_point()+stat_smooth()
ggsave(filename = paste0(resdir,'euclpace-distance_colorrealcollab.png'),width = 15,height=10,units = 'cm')


## constr/coll costs rate
g=ggplot(res,aes(x=collcost/constrcost,y=targetDistance,color=realcollab))
g+geom_point()+stat_smooth()

g=ggplot(res,aes(x=collcost,y=targetDistance,color=realcollab))
g+geom_point()+stat_smooth()

g=ggplot(res,aes(x=collcost,y=targetDistance,color=gametype))
g+geom_point()+stat_smooth()

g=ggplot(res,aes(x=constrcost,y=targetDistance,color=realcollab))
g+geom_point()+stat_smooth()

# at least influence on collaboration rate ?
g=ggplot(res,aes(x=constrcost,y=expcollab,color=targetDistance))
g+geom_point()+stat_smooth()+facet_wrap(~gametype)



g=ggplot(res,aes(x=regionalproba,y=realcollab))
g+geom_point()



