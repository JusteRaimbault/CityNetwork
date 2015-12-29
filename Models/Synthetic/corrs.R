
setwd(paste0(Sys.getenv('CN_HOME'),'/Results/Synthetic/Network'))

res <- read.csv('20151224_LHSLocal/2015_12_24_19_39_03_LHS_LOCAL.csv')

library(dplyr)

gres <- (as.tbl(res) %>% group_by(
  citiesNumber,densityConfig,gravityHierarchyExponent,gravityInflexion,gravityRadius,hierarchyRole,maxNewLinksNumber,
  # DENSITY PARAMETERS)
  )
  
#aggregated summary vars 
aggres <- gres  %>% summarise(bw = mean(meanBwCentrality),bws=sd(meanBwCentrality),
                   pathlength = mean(meanPathLength),pathlengthsd = sd(meanPathLength),
                  relspeed=mean(meanRelativeSpeed),relspeedsd=sd(meanRelativeSpeed),
                  diameter=mean(nwDiameter),diametersd=sd(nwDiameter),
                  length=mean(nwLength))
aggres <- aggres %>% filter(!is.na(bw)&!is.na(bws))

hist(aggres$pathlength,breaks=20)
summary(aggres$pathlengthsd)

plot(aggres[,c(7,9,11,13,15)])

# Test of summarise with list of functions [as strings] -> DOES NOT WORK
#l=list();l[["m"]]="mean(meanBwCentrality)"
#test <- gres %>% summarise(l)



#  compute cov/cor matrix for each point in param space

# nw block
nwcormat <- gres %>% summarise(
        cor12 = cor(meanBwCentrality,meanPathLength),
        cor13 = cor(meanBwCentrality,meanRelativeSpeed),
        cor14 = cor(meanBwCentrality,nwDiameter),
        #cor15 = cor(meanBwCentrality,nwLength),
        cor23 = cor(meanPathLength,meanRelativeSpeed),
        cor24 = cor(meanPathLength,nwDiameter),
        #cor25 = cor(meanPathLength,nwLength),
        cor34 = cor(meanRelativeSpeed,nwDiameter)#,
        #cor35 = cor(meanRelativeSpeed,nwLength),
        #cor45 = cor(nwDiameter,nwLength) 
     )  %>% filter(!is.na(cor12)&!is.na(cor13)&!is.na(cor14)&!is.na(cor23)&!is.na(cor24)&!is.na(cor34))

# density block
denscormat <- gres %>% summarise(
    cor12 = cor(moran,density),
    cor13 = cor(moran,entropy),
    cor14 = cor(moran,slope),
    cor23 = cor(density,entropy),
    cor24 = cor(density,slope),
    cor34 = cor(entropy,slope)
)

# cross correlations
crosscormat <- gres %>% summarise(
   cor15 = cor(meanBwCentrality,moran),
   cor16 = cor(meanBwCentrality,density),
   cor17 = cor(meanBwCentrality,entropy),
   cor18 = cor(meanBwCentrality,slope),
   cor25 = cor(meanPathLength,moran),
   cor26 = cor(meanPathLength,density),
   cor27 = cor(meanPathLength,entropy),
   cor28 = cor(meanPathLength,slope),
   cor35 = cor(meanRelativeSpeed,moran),
   cor36 = cor(meanRelativeSpeed,density),
   cor37 = cor(meanRelativeSpeed,entropy),
   cor38 = cor(meanRelativeSpeed,slope),
   cor45 = cor(nwDiameter,moran),
   cor46 = cor(nwDiameter,density),
   cor47 = cor(nwDiameter,entropy),
   cor48 = cor(nwDiameter,slope)
)


summary(cormat[1,8:17])


# find a way to summarize corr matrices -> various norms ?
#  per var : max ; spread ; ?

# HeatMaps

library(ggplot2)

df=data.frame(z=unlist(cormat[50,8:17]),x=c(2:5,3:5,4:5,5),y=c(rep(1,4),rep(2,3),rep(3,2),4))
ggplot(df, aes(x, y, fill = z)) + geom_raster(hjust = 0, vjust = 0) + scale_colour_continuous(low="green",high="red")



# plot points on two first principal components
pr = prcomp(cormat[,8:17])
rcormat = as.matrix(cormat[,8:17]) %*% as.matrix(pr$rotation)
#plot(rcormat[,1],rcormat[,2])
# color according to mean correlation / other?
#as.tbl(as.data.frame(t(rcormat))) %>% transmute(m=(PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10)/10)
apply(rcormat,1,mean)
ggplot(data.frame(x=rcormat[,1],y=rcormat[,2],meanCor=apply(rcormat,1,mean)),aes(x=x,y=y,colour=meanCor))+geom_point()

# same with max-min and max/min and mean absolute corr
ggplot(data.frame(x=rcormat[,1],y=rcormat[,2],meanCor=apply(rcormat,1,function(l){max(l)-min(l)})),aes(x=x,y=y,colour=meanCor))+geom_point()
ggplot(data.frame(x=rcormat[,1],y=rcormat[,2],meanCor=apply(rcormat,1,max)),aes(x=x,y=y,colour=meanCor))+geom_point()
ggplot(data.frame(x=rcormat[,1],y=rcormat[,2],meanCor=apply(rcormat,1,min)),aes(x=x,y=y,colour=meanCor))+geom_point()
ggplot(data.frame(x=rcormat[,1],y=rcormat[,2],meanCor=apply(cormat[,8:17],1,function(l){mean(abs(l))})),aes(x=x,y=y,colour=meanCor))+geom_point()


# histograms of correlations
# -> log normal ? COMPARE WITH NULL MODEL ? which one ?
hist(cormat$cor14,breaks=100)


##########
# linear models ? (influence of parameters)
#  plot(mean(abs(cor))) agaisnt parameters -> uniform point cloud 
#
#  very shitty in all cases. -> due to repets number : non-significance of corrs, just random conditioned on params ?
fixedConf = 10
ldf = data.frame(y=apply(cormat[which(cormat[,2]==fixedConf),8:17],1,function(l){mean(abs(l))}),cormat[which(cormat[,2]==fixedConf),1:7])
l = lm(y~1+citiesNumber+gravityHierarchyExponent+gravityInflexion+gravityRadius+hierarchyRole+maxNewLinksNumber,ldf)
summary(l)
hist(apply(cormat[,8:17],1,function(l){mean(abs(l))}),breaks=50)
hist(apply(cormat[,8:17],1,function(l){mean(l)}),breaks=50)
hist(apply(cormat[which(cormat[,2]==fixedConf),8:17],1,function(l){mean(abs(l))}),breaks=50)
# cor = 1 -> issue in data ? otherwise mean corr seems relatively gaussian with zero mean.


####### TODO
# sort of space-matters approachs : sensitivity of phase diagram along nw parameters, 
# for ≠ fixed density confs
#  -> 2nd order ? CHECK THAT. AMPLITUDE AND SIGNIFICANCE OF 2ND ORDER DEVIATION.


