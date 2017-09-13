
##
# Second order calibration of mesocoevol model

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/MesoCoevol/analysis'))

library(dplyr)
library(ggplot2)

# real data
raw=read.csv(file=paste0(Sys.getenv('CN_HOME'),"/Models/StaticCorrelations/res/res/europe_areasize100_offset50_factor0.5_20160824.csv"),sep=";",header=TRUE)
rows=apply(raw,1,function(r){prod(as.numeric(!is.na(r)))>0})
res=as.tbl(raw[rows,])


# simulation data
#sim = as.tbl(read.csv(file='../MesoCoevol/exploration/2017_03_16_22_39_56_CONNEXION_LHS_GRID.csv',sep=',',header=T))
#sim = as.tbl(read.csv(file='../MesoCoevol/exploration/2017_03_16_22_42_58_GRAVITY_LHS_GRID.csv',sep=',',header=T))
#sim = as.tbl(read.csv(file='../MesoCoevol/exploration/2017_03_16_22_44_55_BIOLOGICAL_LHS_GRID.csv',sep=',',header=T))
sim = as.tbl(read.csv(file='../MesoCoevol/exploration/2017_09_10_14_29_46_LHS.csv',sep=',',header=T))

# get measures only
sres = sim %>% group_by(id,replication) %>% summarise(
  moran=mean(moran),entropy=mean(entropy),distance=mean(distance),slope=mean(slope),
  meanBwCentrality=mean(meanBwCentrality),meanPathLength=mean(meanPathLength),
  meanRelativeSpeed=mean(meanRelativeSpeed),nwDiameter=mean(nwDiameter),
  meanClosenessCentrality=mean(meanClosenessCentrality)
)


# Q : do pca separately horizontally (sim/real) and vertically (morphology/network)
#   -> check analytically what is means for correlations.

# ocnstruct single data frame
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
                 type=c(rep("real",nrow(res)),rep("sim",nrow(sres)))
                 )
)
             
# renormalize
for(j in 1:(ncol(all)-2)){all[,j]=(all[,j]-min(all[,j]))/(max(all[,j])-min(all[,j]))}

vars = 1:8
pr <- prcomp(all[,vars]);rot=pr$rotation
pcall = as.data.frame(as.matrix(all[,vars])%*%pr$rotation)
pcall$type = all$type

g=ggplot(pcall,aes(x=PC1,y=PC2,col=type))
g+geom_point(size=0.3)



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





