
##
# Second order calibration of mesocoevol model

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/MesoCoevol/analysis'))

library(dplyr)

# real data
raw=read.csv(file=paste0(Sys.getenv('CN_HOME'),"/Models/StaticCorrelations/res/res/europe_areasize100_offset50_factor0.5_20160824.csv"),sep=";",header=TRUE)
rows=apply(raw,1,function(r){prod(as.numeric(!is.na(r)))>0})
res=raw[rows,]


# simulation data
#sim = as.tbl(read.csv(file='../MesoCoevol/exploration/2017_03_16_22_39_56_CONNEXION_LHS_GRID.csv',sep=',',header=T))
#sim = as.tbl(read.csv(file='../MesoCoevol/exploration/2017_03_16_22_42_58_GRAVITY_LHS_GRID.csv',sep=',',header=T))
sim = as.tbl(read.csv(file='../MesoCoevol/exploration/2017_03_16_22_44_55_BIOLOGICAL_LHS_GRID.csv',sep=',',header=T))


# Q : do pca separately horizontally (sim/real) and vertically (morphology/network)
#   -> check analytically what is means for correlations.

# ocnstruct single data frame
all = data.frame(moran=c(res$moran,sim$moran),
                 entropy=c(res$entropy,sim$entropy),
                 distance=c(res$distance,sim$distance),
                 slope = c(res$slope,sim$slope),
                 #diameter = c(res$diameter,sim$),
                 meanPathLength = c(res$meanPathLength,sim$meanPathLength),
                 meanBetweenness = c(res$meanBetweenness,sim$meanBwCentrality),
                 meanCloseness = c(res$meanCloseness,sim$meanClosenessCentrality),
                 networkPerf = c(res$networkPerf,sim$meanRelativeSpeed),
                 id=c(paste0("r",floor(res$lonmin),floor(res$latmin)),paste0("s",sim$id)),
                 type=c(rep("real",nrow(res)),rep("sim",nrow(sim)))
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
sim = sim[sim$id==2,]

alls = all[all$type=='sim',vars]
allr = all[all$type=='real',vars]
sum((cor(alls) - cor(allr))^2)

s=all[all$type=='sim',vars]
dists=c();rows=c()
for(i in 1:nrow(sim)){
  show(i)
#dists = apply(all[all$type=='real',vars],1,function(r){sqrt(sum((r-s[i,])^2))})
mr=as.matrix(all[all$type=='real',vars]);ms=matrix(rep(as.numeric(s[i,]),nrow(res)),nrow = nrow(res),byrow=T)
d2 = (mr-ms)^2
dists = append(dists,min(rowSums(d2)));rows=append(rows,which(rowSums(d2)==min(rowSums(d2))))
}

sum((cor(allr[unique(rows),]) - cor(alls))^2)





