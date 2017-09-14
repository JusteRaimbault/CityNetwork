
##
# Second order calibration of mesocoevol model

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/MesoCoevol/analysis'))

library(dplyr)
library(ggplot2)
source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))


# real data
raw=read.csv(file=paste0(Sys.getenv('CN_HOME'),"/Models/StaticCorrelations/res/res/europe_areasize100_offset50_factor0.5_20160824.csv"),sep=";",header=TRUE)
rows=apply(raw,1,function(r){prod(as.numeric(!is.na(r)))>0})
res=as.tbl(raw[rows,])
res=res[res$meanCloseness<0.3,]
#nwindics=c("meanPathLength","meanCloseness")#,"meanBetweenness")
#for(j in nwindics){res[,j]<-(res[,j]-min(res[,j]))/(max(res[,j])-min(res[,j]))}


# correlation data (computed in StaticCorrelations/corrs.R)
rhoasize=8;step=4
load(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations/res/res/corrmat_asize',rhoasize,'_step',step,'.RData'))

# simulation data
#sim = as.tbl(read.csv(file='../MesoCoevol/exploration/2017_03_16_22_39_56_CONNEXION_LHS_GRID.csv',sep=',',header=T))
#sim = as.tbl(read.csv(file='../MesoCoevol/exploration/2017_03_16_22_42_58_GRAVITY_LHS_GRID.csv',sep=',',header=T))
#sim = as.tbl(read.csv(file='../MesoCoevol/exploration/2017_03_16_22_44_55_BIOLOGICAL_LHS_GRID.csv',sep=',',header=T))
# full simulations
sim = as.tbl(read.csv(file='../MesoCoevol/exploration/2017_09_10_14_29_46_LHS.csv',sep=',',header=T))
resdir=paste0(Sys.getenv('CN_HOME'),'/Results/MesoCoevol/Calib/20170910_lhs/');dir.create(resdir)

rows=apply(sim,1,function(r){ifelse(length(which(is.na(r)))>0,F,T)})
sim = sim[rows,]
sim=sim[sim$meanClosenessCentrality<0.3,]

heuristics = c("random","connexion","det-brkdn","rnd-brkdn","cost","biological")

# get measures only
sres = sim %>% group_by(id,replication) %>% summarise(
  moran=mean(moran),entropy=mean(entropy),distance=mean(distance),slope=mean(slope),
  meanBwCentrality=mean(meanBwCentrality),meanPathLength=mean(meanPathLength),
  meanRelativeSpeed=mean(meanRelativeSpeed),nwDiameter=mean(nwDiameter),
  meanClosenessCentrality=mean(meanClosenessCentrality),
  heuristic=mean(nwHeuristic),
  maxNewLinksNumber=mean(maxNewLinksNumber),nwUpdateTime=mean(nwUpdateTime),gravityRadius=mean(gravityRadius),gravityInflexion=mean(gravityInflexion),
  gravityHierarchyWeight=mean(gravityHierarchyWeight),gravityHierarchyExponent=mean(gravityHierarchyExponent),breakdownHierarchy=mean(breakdownHierarchy),breakdownThreshold=mean(breakdownThreshold),costTradeoff=mean(costTradeoff),bioThreshold=mean(bioThreshold),bioSteps=mean(bioSteps)
)

sres$heuristic=heuristics[sres$heuristic+1]

#indics=c("moran","entropy","distance","slope","meanBwCentrality","meanPathLength","meanRelativeSpeed","nwDiameter","meanClosenessCentrality")
#for(j in indics){if(max(sres[,j])>min(sres[,j])){sres[,j]<-(sres[,j]-min(sres[,j]))/(max(sres[,j])-min(sres[,j]))}else{sres[,j]=0}}



# construct single data frame
all = as.tbl(data.frame(moran=c(res$moran,sres$moran),
                 entropy=c(res$entropy,sres$entropy),
                 distance=c(res$distance,sres$distance),
                 slope = c(res$slope,sres$slope),
                 #diameter = c(res$diameter,sim$),
                 meanPathLength = c(res$meanPathLength,sres$meanPathLength),
                 meanBetweenness = c(res$meanBetweenness,sres$meanBwCentrality),
                 meanCloseness = c(res$meanCloseness,sres$meanClosenessCentrality),
                 networkPerf = c(res$networkPerf,sres$meanRelativeSpeed),
                 id=c(paste0("r",floor(res$lonmin),floor(res$latmin)),paste0("s",sres$id)),
                 type=c(rep("real",nrow(res)),rep("sim",nrow(sres))),
                 heuristic=c(rep("real",nrow(res)),sres$heuristic)
                 )
)

summary(all[all$type=='real',])
summary(all[all$type=='sim',])
             
# renormalize
for(j in 1:(ncol(all)-3)){all[,j]=(all[,j]-min(all[,j]))/(max(all[,j])-min(all[,j]))}

vars = c("moran","entropy","distance","slope","meanPathLength","meanBetweenness","meanCloseness")
pr <- prcomp(all[,vars]);rot=pr$rotation
pcall = as.data.frame(as.matrix(all[,vars])%*%pr$rotation)
pcall$type = all$type;pcall$heuristic=all$heuristic

g=ggplot(pcall,aes(x=PC1,y=PC2,col=type))
g+geom_point(pch='.')+stdtheme
ggsave(paste0(resdir,'pca_allobjs.png'),width=18,height=15,units='cm')

g=ggplot(pcall,aes(x=PC1,y=PC2,col=heuristic))
g+geom_point(size=0.5,alpha=0.8)+ guides(colour = guide_legend(override.aes = list(size=5)))+stdtheme
ggsave(paste0(resdir,'pca_byheuristic.png'),width=21,height=18,units = 'cm')

# same with morpho only
vars = c("moran","entropy","distance","slope")
pr <- prcomp(all[,vars]);rot=pr$rotation;summary(pr)
pcall = as.data.frame(as.matrix(all[,vars])%*%pr$rotation)
pcall$type = all$type;pcall$heuristic=all$heuristic

g=ggplot(pcall,aes(x=PC1,y=PC2,col=type))
g+geom_point(pch='.')+stdtheme+ggtitle("Morphological indicators")
ggsave(paste0(resdir,'pca_morpho.png'),width=18,height=15,units='cm')

g=ggplot(pcall,aes(x=PC1,y=PC2,col=heuristic))
g+geom_point(size=0.5,alpha=0.8)+ guides(colour = guide_legend(override.aes = list(size=5)))+stdtheme
ggsave(paste0(resdir,'pca_morpho_byheuristic.png'),width=21,height=18,units = 'cm')


# same with network only
vars = c("meanPathLength","meanBetweenness","meanCloseness")
pr <- prcomp(all[,vars]);rot=pr$rotation;summary(pr)
pcall = as.data.frame(as.matrix(all[,vars])%*%pr$rotation)
pcall$type = all$type;pcall$heuristic=all$heuristic

g=ggplot(pcall,aes(x=PC1,y=PC2,col=type))
g+geom_point(pch='.')+stdtheme+ggtitle("Network indicators")
ggsave(paste0(resdir,'pca_network.png'),width=18,height=15,units='cm')

g=ggplot(pcall,aes(x=PC1,y=PC2,col=heuristic))
g+geom_point(size=0.5,alpha=0.8)+ guides(colour = guide_legend(override.aes = list(size=5)))+stdtheme
ggsave(paste0(resdir,'pca_network_byheuristic.png'),width=21,height=18,units = 'cm')



###################
###################

# correlation distances

# compute correlations on parameter neighbors for the simulation

# for each heuristic :
#  - cut the parameter space to have reasonable number of points
#  - summarise indics and compute correlations in each bin
#  - find closest param point with closest corr mat

vars = c("moran","entropy","distance","slope","meanPathLength","meanBetweenness","meanCloseness")
corrsnames = c("moran.entropy","moran.distance","moran.slope","moran.meanPathLength","moran.meanBetweenness","moran.meanCloseness",
              "entropy.distance","entropy.slope","entropy.meanPathLength","entropy.meanBetweenness","entropy.meanCloseness",
              "distance.slope","distance.meanPathLength","distance.meanBetweenness","distance.meanCloseness",
              "slope.meanPathLength","slope.meanBetweenness","slope.meanCloseness",
              "meanPathLength.meanBetweenness","meanPathLength.meanCloseness","meanBetweenness.meanCloseness"
              )
realcorrs = corrmat[,c("lon","lat",corrsnames)]

# TODO : filter on significant correlation (in the sense of non zero)


# augmented corr matrix to ease distance computation -- dirty
mr=as.matrix(all[all$type=='real',vars])
rows=c();for(i in 1:nrow(mr)){if(i%%10000==0){show(i)};d=abs(realcorrs$lon-unlist(res[i,1]))+abs(realcorrs$lat-unlist(res[i,2]));row=which(d==min(d))[1];rows=append(rows,row)}
cr = realcorrs[rows,c(-1,-2)]

heuristics = c("random","connexion","det-brkdn","rnd-brkdn","cost","biological")
commonparams = c("maxNewLinksNumber","nwUpdateTime")
params = list("random"=c(),"connexion"=c(),
   "det-brkdn"=c("gravityRadius","gravityInflexion","gravityHierarchyWeight","gravityHierarchyExponent"),
   "rnd-brkdn"=c("gravityRadius","gravityHierarchyExponent","breakdownHierarchy","breakdownThreshold"),
   "cost"=c("costTradeoff"),"biological"=c("bioThreshold","bioSteps")
              )

closestRealPoint<-function(currentsim){
  currentcorrs = currentsim%>%group_by(ids)%>%summarise(
    moran.entropy=cor(moran,entropy),moran.distance=cor(moran,distance),moran.slope=cor(moran,slope),moran.meanPathLength=cor(moran,meanPathLength),moran.meanBetweenness=cor(moran,meanBwCentrality),moran.meanCloseness=cor(moran,meanClosenessCentrality),
    entropy.distance=cor(entropy,distance),entropy.slope=cor(entropy,slope),entropy.meanPathLength=cor(entropy,meanPathLength),entropy.meanBetweenness=cor(entropy,meanBwCentrality),entropy.meanCloseness=cor(entropy,meanClosenessCentrality),
    distance.slope=cor(distance,slope),distance.meanPathLength=cor(distance,meanPathLength),distance.meanBetweenness=cor(distance,meanBwCentrality),distance.meanCloseness=cor(distance,meanClosenessCentrality),
    slope.meanPathLength=cor(slope,meanPathLength),slope.meanBetweenness=cor(slope,meanBwCentrality),slope.meanCloseness=cor(slope,meanClosenessCentrality),
    meanPathLength.meanBetweenness=cor(meanPathLength,meanBwCentrality),meanPathLength.meanCloseness=cor(meanPathLength,meanClosenessCentrality),
    meanBetweenness.meanCloseness=cor(meanBwCentrality,meanClosenessCentrality),
    moran=mean(moran),entropy=mean(entropy),distance=mean(distance),slope=mean(slope),
    meanBetweenness=mean(meanBwCentrality),meanPathLength=mean(meanPathLength),
    meanCloseness=mean(meanClosenessCentrality)
  )
  
  show(nrow(currentcorrs))
  
  dists=c();rows=c();optlon=c();optlat=c();distsindics=c();distscorrs=c();abscorrs=c()
  for(i in 1:nrow(currentcorrs)){
    if(i%%10==0){show(i)}
    ms=matrix(rep(as.numeric(currentcorrs[i,vars]),nrow(res)),nrow = nrow(res),byrow=T)
    d2indicsmat = (mr-ms)^2
    ms=matrix(rep(as.numeric(currentcorrs[i,corrsnames]),nrow(res)),nrow = nrow(res),byrow=T)
    d2corrsmat = (cr-ms)^2
    #distscorrs = append(distscorrs,min(rowSums(d2corrs)));
    #plot(rowMeans(d2corrs),rowMeans(d2indics))
    # -> take the sum of means, should be reasonnable
    d2corrs=rowMeans(d2indicsmat);d2indics=rowMeans(d2indicsmat)
    d2 = d2corrs+d2indics;row=which(min(d2)==d2)
    dists=append(dists,min(d2));rows=append(rows,row)
    distsindics=append(distsindics,d2indics[row]);distscorrs=append(distscorrs,d2corrs[row]);
    optlon=append(optlon,res[row,1]);optlat=append(optlat,res[row,2]);
    abscorrs=append(abscorrs,mean(abs(unlist(currentcorrs[i,corrsnames]))))
  }
  return(list(d2=dists,row=rows,d2indics=distsindics,d2corrs=distscorrs,optlon=optlon,optlat=optlat,abscorrs=abscorrs))
}

    

dists=c();rows=c();optlon=c();optlat=c();cheur=c()
distsindics=c();distscorrs=c()
abscorrs=c()

for(heuristic in unique(floor(sim$nwHeuristic))){
  heurname = heuristics[heuristic+1];show(heurname)
  currentsim = sres[sres$heuristic==heurname,]
  currentparams = c(commonparams, params[[heurname]])
  ids=c();for(param in currentparams){currentsim[[param]]=cut(currentsim[[param]],floor(15/length(currentparams)));ids=paste0(ids,as.character(currentsim[[param]]))}
  currentsim$ids = ids
  #currentsim%>%group_by(ids)%>%summarise(count=n())
  
  # for each row, compute and aggregate indicators distance and correlation distance
  opt = closestRealPoint(currentsim)
  dists=append(dists,opt$d2);rows=append(rows,opt$rows)
  distsindics=append(distsindics,opt$d2indics);distscorrs=append(distscorrs,opt$d2corrs);
  optlon=append(optlon,opt$optlon);optlat=append(optlat,opt$optlat);cheur=append(cheur,rep(heurname,length(opt$d2)))
  abscorrs=append(abscorrs,opt$abscorrs)
}


# null model : shuffle completely simulation rows : should yield null correlations.
#nbootstraps=10
#for(b in 1:nbootstraps){
  currentsim=sres
  currentsim$ids=sample.int(n = 700,size = nrow(currentsim),replace = T)
  opt = closestRealPoint(currentsim)
#}
#save(opt,file='res/corrnullmodel.RData')
#

g=ggplot(data.frame(distance=dists,heuristic=cheur),aes(x=distance,color=heuristic))
g+geom_density()
# -> should also filter on significativity ?




####################
####################

# causality regimes

source('causalityFuns.R')

resdir=paste0(Sys.getenv('CN_HOME'),'/Results/MesoCoevol/Calib/20170910_lhs/causalities');dir.create(resdir)





####################
####################

# Q : do pca separately horizontally (sim/real) and vertically (morphology/network)
#   -> check analytically what is means for correlations.

#### Check correlations

#sim = sim[sim$id==2,]

alls = all[all$type=='sim',vars]
allr = all[all$type=='real',vars]
mean((cor(alls) - cor(allr))^2)
mean(abs(cor(alls) - cor(allr)))


s=all[all$type=='sim',vars]
dists=c();rows=c()
for(i in 1:nrow(sres)){
  show(i)
#dists = apply(all[all$type=='real',vars],1,function(r){sqrt(sum((r-s[i,])^2))})
mr=as.matrix(all[all$type=='real',vars]);ms=matrix(rep(as.numeric(s[i,]),nrow(res)),nrow = nrow(res),byrow=T)
d2 = (mr-ms)^2
dists = append(dists,min(rowSums(d2)));rows=append(rows,which(rowSums(d2)==min(rowSums(d2))))
}

sum((cor(allr[unique(rows),]) - cor(alls))^2)





