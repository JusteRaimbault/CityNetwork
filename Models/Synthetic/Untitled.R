
setwd(paste0(Sys.getenv('CN_HOME'),'/Results/Synthetic/Network'))

res <- read.csv('20151224_LHSLocal/2015_12_24_19_39_03_LHS_LOCAL.csv')

library(dplyr)

gres <- (as.tbl(res) %>% group_by(citiesNumber,densityConfig,gravityHierarchyExponent,gravityInflexion,gravityRadius,hierarchyRole,maxNewLinksNumber))
aggres <- gres %>% summarise(bw = mean(meanBwCentrality),bws=sd(meanBwCentrality),
                   pathlength = mean(meanPathLength),pathlengthsd = sd(meanPathLength),
                  relspeed=mean(meanRelativeSpeed),relspeedsd=sd(meanRelativeSpeed),
                  diameter=mean(nwDiameter),diametersd=sd(nwDiameter),
                  length=mean(nwLength))

hist(aggres$pathlength,breaks=20)
summary(aggres$pathlengthsd)

plot(aggres[,c(7,9,11,13,15)])



#  compute cov/cor matrix for each point in param space
cormat <- gres %>% summarise(cor = cor(meanBwCentrality,meanPathLength))


# find a way to summarize corr matrices -> various norms ?
#  per var : max ; spread ; ?