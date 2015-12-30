
setwd(paste0(Sys.getenv('CN_HOME'),'/Results/Synthetic/Network'))

#res <- read.csv('20151224_LHSLocal/2015_12_24_19_39_03_LHS_LOCAL.csv')
res <- read.csv('20151227_LHSDensityNW_Local/2015_12_27_13_50_52_LHS_DENSITYNW_DIRAC.csv')
#res <- read.csv('20151229_LHSDensityNW/2015_12_29_19_04_41_LHS_DENSITYNW_DIRAC.csv')

library(dplyr)

gres <- as.tbl(res) %>% group_by(idpar)
  #citiesNumber,densityConfig,gravityHierarchyExponent,gravityInflexion,gravityRadius,hierarchyRole,maxNewLinksNumber,
  #alphalocalization,)
  
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

# need to filter on group size
glength <- gres %>% summarise(groupLength = length(idpar))
glength$idpar[glength$groupLength==50]

#  compute cov/cor matrix for each point in param space

# nw block
#  no nwLength for the sake of simplicity
nwcormat <- gres %>% filter(idpar %in% glength$idpar[glength$groupLength>=50]) %>% summarise(
        cor12 = cor(meanBwCentrality,meanPathLength),
        cor13 = cor(meanBwCentrality,meanRelativeSpeed),
        cor14 = cor(meanBwCentrality,nwDiameter),
        cor23 = cor(meanPathLength,meanRelativeSpeed),
        cor24 = cor(meanPathLength,nwDiameter),
        cor34 = cor(meanRelativeSpeed,nwDiameter)
     )  #%>% filter(!is.na(cor12)&!is.na(cor13)&!is.na(cor14)&!is.na(cor23)&!is.na(cor24)&!is.na(cor34))

# density block
denscormat <- gres %>% filter(idpar %in% glength$idpar[glength$groupLength>=50]) %>%  summarise(
    cor12 = cor(moran,distance),
    cor13 = cor(moran,entropy),
    cor14 = cor(moran,slope),
    cor23 = cor(distance,entropy),
    cor24 = cor(distance,slope),
    cor34 = cor(entropy,slope)
) #%>% filter(!is.na(cor12)&!is.na(cor13)&!is.na(cor14)&!is.na(cor23)&!is.na(cor24)&!is.na(cor34))


# cross correlations -- hardcore with CIs
crosscormat <- gres  %>% filter(idpar %in% glength$idpar[glength$groupLength>=50]) %>% summarise(
   cor15 = cor.test(meanBwCentrality,moran,method="pearson",conf.level=0.95)$estimate,cor15min = cor.test(meanBwCentrality,moran,method="pearson",conf.level=0.95)$conf.int[1],cor15max = cor.test(meanBwCentrality,moran,method="pearson",conf.level=0.95)$conf.int[2],
   cor16 = cor.test(meanBwCentrality,distance,method="pearson",conf.level=0.95)$estimate,cor16min = cor.test(meanBwCentrality,distance,method="pearson",conf.level=0.95)$conf.int[1],cor16max = cor.test(meanBwCentrality,distance,method="pearson",conf.level=0.95)$conf.int[2],
   cor17 = cor.test(meanBwCentrality,entropy,method="pearson",conf.level=0.95)$estimate,cor17min = cor.test(meanBwCentrality,entropy,method="pearson",conf.level=0.95)$conf.int[1],cor17max = cor.test(meanBwCentrality,entropy,method="pearson",conf.level=0.95)$conf.int[2],
   cor18 = cor.test(meanBwCentrality,slope,method="pearson",conf.level=0.95)$estimate,cor18min = cor.test(meanBwCentrality,slope,method="pearson",conf.level=0.95)$conf.int[1],cor18max = cor.test(meanBwCentrality,slope,method="pearson",conf.level=0.95)$conf.int[2],
   cor25 = cor.test(meanPathLength,moran,method="pearson",conf.level=0.95)$estimate,cor25min = cor.test(meanPathLength,moran,method="pearson",conf.level=0.95)$conf.int[1],cor25max = cor.test(meanPathLength,moran,method="pearson",conf.level=0.95)$conf.int[2],
   cor26 = cor.test(meanPathLength,distance,method="pearson",conf.level=0.95)$estimate,cor26min = cor.test(meanPathLength,distance,method="pearson",conf.level=0.95)$conf.int[1],cor26max = cor.test(meanPathLength,distance,method="pearson",conf.level=0.95)$conf.int[2],
   cor27 = cor.test(meanPathLength,entropy,method="pearson",conf.level=0.95)$estimate,cor27min = cor.test(meanPathLength,entropy,method="pearson",conf.level=0.95)$conf.int[1],cor27max = cor.test(meanPathLength,entropy,method="pearson",conf.level=0.95)$conf.int[2],
   cor28 = cor.test(meanPathLength,slope,method="pearson",conf.level=0.95)$estimate,cor28min = cor.test(meanPathLength,slope,method="pearson",conf.level=0.95)$conf.int[1],cor28max = cor.test(meanPathLength,slope,method="pearson",conf.level=0.95)$conf.int[2],
   cor35 = cor.test(meanRelativeSpeed,moran,method="pearson",conf.level=0.95)$estimate,cor35min = cor.test(meanRelativeSpeed,moran,method="pearson",conf.level=0.95)$conf.int[1],cor35max = cor.test(meanRelativeSpeed,moran,method="pearson",conf.level=0.95)$conf.int[2],
   cor36 = cor.test(meanRelativeSpeed,distance,method="pearson",conf.level=0.95)$estimate,cor36min = cor.test(meanRelativeSpeed,distance,method="pearson",conf.level=0.95)$conf.int[1],cor36max = cor.test(meanRelativeSpeed,distance,method="pearson",conf.level=0.95)$conf.int[2],
   cor37 = cor.test(meanRelativeSpeed,entropy,method="pearson",conf.level=0.95)$estimate,cor37min = cor.test(meanRelativeSpeed,entropy,method="pearson",conf.level=0.95)$conf.int[1],cor37max = cor.test(meanRelativeSpeed,entropy,method="pearson",conf.level=0.95)$conf.int[2],
   cor38 = cor.test(meanRelativeSpeed,slope,method="pearson",conf.level=0.95)$estimate,cor38min = cor.test(meanRelativeSpeed,slope,method="pearson",conf.level=0.95)$conf.int[1],cor38max = cor.test(meanRelativeSpeed,slope,method="pearson",conf.level=0.95)$conf.int[2],
   cor45 = cor.test(nwDiameter,moran,method="pearson",conf.level=0.95)$estimate,cor45min = cor.test(nwDiameter,moran,method="pearson",conf.level=0.95)$conf.int[1],cor45max = cor.test(nwDiameter,moran,method="pearson",conf.level=0.95)$conf.int[2],
   cor46 = cor.test(nwDiameter,distance,method="pearson",conf.level=0.95)$estimate,cor46min = cor.test(nwDiameter,distance,method="pearson",conf.level=0.95)$conf.int[1],cor46max = cor.test(nwDiameter,distance,method="pearson",conf.level=0.95)$conf.int[2],
   cor47 = cor.test(nwDiameter,entropy,method="pearson",conf.level=0.95)$estimate,cor47min = cor.test(nwDiameter,entropy,method="pearson",conf.level=0.95)$conf.int[1],cor47max = cor.test(nwDiameter,entropy,method="pearson",conf.level=0.95)$conf.int[2],
   cor48 = cor.test(nwDiameter,slope,method="pearson",conf.level=0.95)$estimate,cor48min = cor.test(nwDiameter,slope,method="pearson",conf.level=0.95)$conf.int[1],cor48max = cor.test(nwDiameter,slope,method="pearson",conf.level=0.95)$conf.int[2]
)


summary(cormat[1,8:17])



# histograms of correlations
# -> log normal ? COMPARE WITH NULL MODEL ? which one ?
par(mfrow=c(2,3))
for(j in 1:ncol(cormat)){
  hist(cormat[[colnames(cormat)[j]]],breaks=30,main=colnames(cormat)[j],xlab="")
  #corj = cormat[[colnames(cormat)[j]]];show(mean(corj))
  #rho = mean(corj)
  # simulate correlated vectors of same size
  corrs = c();for(k in 1:1000){x1 = rnorm(1000,mean=0);corrs=append(corrs,cor(x1,rho*x1 +sqrt(1 - rho^2)*rnorm(1000,mean=0)))}
  #ggplot(vegLengths, aes(length, fill = veg)) + geom_histogram(alpha = 0.5, aes(y = ..density..), position = 'identity')
}


# test : pairwise correlations of subvectors ?
# - 50 subvector size ; idpar == 0
#
#  -- THIS IS BOOTSTRAP --
#
point=1;subvecsize=20;subsamplesize=2000;
fgres <- gres %>% filter(idpar==point)
subsample = sample.int(n=nrow(fgres),size=subsamplesize,replace=FALSE);fgres <- fgres[subsample,]
fgres <- fgres %>% mutate(row=1:nrow(fgres)) %>% mutate(subvec=floor((row-1)/subvecsize)+1)
corrs = c();subvecnum=max(fgres$subvec)-1;
for(i in 1:subvecnum){corrs = append(corrs,cor(c(as.data.frame(fgres%>%filter(subvec==i))$moran),as.data.frame(fgres%>%filter(subvec==i))$meanBwCentrality));}
hist(corrs,breaks=50);mean(corrs);

#
cor.test(fgres$moran,fgres$meanBwCentrality,method="pearson")$estimate
library(boot)
boot(fgres,function(data,i){cor(data$moran[i],data$meanBwCentrality[i])},1000)

# find a way to summarize corr matrices -> various norms ?
#  per var : max ; spread ; ?

# HeatMaps

library(ggplot2)

df=data.frame(z=unlist(cormat[50,8:17]),x=c(2:5,3:5,4:5,5),y=c(rep(1,4),rep(2,3),rep(3,2),4))
ggplot(df, aes(x, y, fill = z)) + geom_raster(hjust = 0, vjust = 0) + scale_colour_continuous(low="green",high="red")




cormat = crosscormat[,2:ncol(crosscormat)]
#cormat = nwcormat[,2:17]

# plot points on two first principal components

corrCols = 3*(0:floor((ncol(cormat)-1)/3))+1
pr = prcomp(cormat[,corrCols])
rcormat = as.matrix(cormat[,corrCols]) %*% as.matrix(pr$rotation)
rcormatmin = as.matrix(cormat[,corrCols+1]) %*% as.matrix(pr$rotation)
rcormatmax = as.matrix(cormat[,corrCols+2]) %*% as.matrix(pr$rotation)
#plot(rcormat[,1],rcormat[,2])
# color according to mean correlation / other?
#as.tbl(as.data.frame(t(rcormat))) %>% transmute(m=(PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10)/10)
#apply(rcormat,1,mean)
npoints = 239;points = sample.int(nrow(rcormat),size=npoints,replace=TRUE)
# must filter according to extent -> minimize overlap and maximize total extent.
# Q : what about "real" morpho conf ?

g = ggplot(data.frame(x=rcormat[points,1],y=rcormat[points,2],xmin=rcormatmin[points,1],xmax=rcormatmax[points,1],ymin=rcormatmin[points,2],ymax=rcormatmax[points,2],meanCor=apply(rcormat,1,function(l){mean(abs(l))})[points]),aes(x=x,y=y,colour=meanCor))
g+geom_point()+geom_errorbar(aes(ymin=ymin,ymax=ymax),width=0.02)+geom_errorbarh(aes(xmin=xmin,xmax=xmax),height=0.02)

# same with max-min and max/min and mean absolute corr
ggplot(data.frame(x=rcormat[,1],y=rcormat[,2],meanCor=apply(rcormat,1,function(l){max(l)-min(l)})),aes(x=x,y=y,colour=meanCor))+geom_point()
ggplot(data.frame(x=rcormat[,1],y=rcormat[,2],meanCor=apply(rcormat,1,max)),aes(x=x,y=y,colour=meanCor))+geom_point()
ggplot(data.frame(x=rcormat[,1],y=rcormat[,2],meanCor=apply(rcormat,1,min)),aes(x=x,y=y,colour=meanCor))+geom_point()
ggplot(data.frame(x=rcormat[,1],y=rcormat[,2],meanCor=apply(cormat,1,function(l){mean(abs(l))})),aes(x=x,y=y,colour=meanCor))+geom_point()




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


