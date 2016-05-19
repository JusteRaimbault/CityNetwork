
# analysis of exploration results

library(dplyr)
library(ggplot2)

setwd(paste0(Sys.getenv('CN_HOME'),'/Results/NetworkNecessity/InteractionGibrat/explo/test'))

res <- as.tbl(read.csv('2016_05_19_16_21_35_LHS_GRID_LOCAL.csv'))

#
#m = lm(logmse~gravityDecay+gravityGamma+gravityWeight+growthRate,res)

d <- res %>% mutate(gfg=floor(feedbackGamma*6)/6,ggd=floor(gravityDecay/100)*100)
res%>%group_by(growthRate)%>%summarise(logmse=mean(logmse))

d=res[which(res$growthRate==0.007),]
gp = ggplot(d,aes(x=feedbackDecay,y=logmse,colour=feedbackGamma))
gp+geom_point()+facet_grid(gravityDecay~gravityGamma)+stat_smooth()





# 
calib <- as.tbl(read.csv('2016_05_19_calib/population27.csv'))
