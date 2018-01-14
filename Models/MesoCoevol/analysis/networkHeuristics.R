
setwd(paste0(Sys.getenv('CN_HOME'),'/Models/MesoCoevol'))

library(dplyr)
library(ggplot2)
library(rgdal)
library(rgeos)
source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

res <- as.tbl(read.csv('MesoCoevol/exploration/2017_08_18_08_05_31_NETWORK_LHS_GRID.csv'))

res$heuristic = floor(res$nwHeuristic)
res$meanBwCentrality<-as.numeric(as.character(res$meanBwCentrality))
res$meanPathLength<-as.numeric(as.character(res$meanPathLength))
res$nwDiameter<-as.numeric(as.character(res$nwDiameter))
res$meanRelativeSpeed<-as.numeric(as.character(res$meanRelativeSpeed))
res$meanClosenessCentrality<-as.numeric(as.character(res$meanClosenessCentrality))

res=res[!is.na(sres$meanBwCentrality),]
res=res[res$meanClosenessCentrality<2,]

# heuristic names
heuristics = c("random","connexion","det-brkdn","rnd-brkdn","cost","biological")

# grid caracs
gridcaracs = as.tbl(read.csv('MesoCoevol/setup/fixeddensity/grids_clust.csv',sep=';'))


resdir=paste0(Sys.getenv('CN_HOME'),'/Results/MesoCoevol/Network/20170818/');dir.create(resdir)


####
# topology of produced networks by heuristic (and possibly grid class)

sres = res%>%group_by(id,densityConf)%>%summarise(
  meanBwCentrality=mean(meanBwCentrality),meanPathLength=mean(meanPathLength),
  meanRelativeSpeed=mean(meanRelativeSpeed),nwDiameter=mean(nwDiameter),
  meanClosenessCentrality=mean(meanClosenessCentrality),heuristic=mean(heuristic)
)

sres=sres[!is.na(sres$meanBwCentrality),]
sres$morpho = gridcaracs$cluster[sres$densityConf]
sres$heuristic=heuristics[sres$heuristic+1]

nres=sres

# pca
for(j in 3:7){nres[,j]<-(nres[,j]-min(nres[,j]))/(max(nres[,j])-min(nres[,j]))}

pca=prcomp(nres[,3:7])
nres=as.tbl(cbind(data.frame(nres),data.frame(as.matrix(data.frame(nres[,3:7]))%*%pca$rotation)))

pca;summary(pca)

g=ggplot(nres,aes(x=PC1,y=PC2,color=heuristic))
g+geom_point(size=0.5,alpha=0.8)+ guides(colour = guide_legend(override.aes = list(size=5)))+stdtheme
ggsave(paste0(resdir,'feasible_space_pca.png'),width=21,height=18,units = 'cm')

# feasible space by morphological class
g=ggplot(nres,aes(x=PC1,y=PC2,color=heuristic))
g+geom_point(size=0.5,alpha=0.8)+facet_wrap(~morpho)+
  guides(colour = guide_legend(override.aes = list(size=5)))+stdtheme+theme(legend.position = c(0.8,0.2))
ggsave(paste0(resdir,'feasible_space_pca_bymorph.png'),width=30,height=21,units = 'cm')



######
## covered space
nres$cell = paste0(as.character(cut(nres$PC1,breaks = 20)),as.character(cut(nres$PC2,breaks = 20)))
gnres = nres%>%group_by(cell)%>%summarise(p1=length(which(heuristic=="biological"))/n(),p2=length(which(heuristic=="connexion"))/n(),p3=length(which(heuristic=="cost"))/n(),p4=length(which(heuristic=="det-brkdn"))/n(),p5=length(which(heuristic=="random"))/n(),p6=length(which(heuristic=="rnd-brkdn"))/n(),count=n())%>%
  mutate(concentration=p1^2+p2^2+p3^2+p4^2+p5^2+p6^2)
summary(gnres$concentration)



####
# distance to real network : 
#   - compare effective dimensions of pca

raw=read.csv(file=paste0(Sys.getenv('CN_HOME'),"/Models/StaticCorrelations/res/res/europe_areasize100_offset50_factor0.5_20160824.csv"),sep=";",header=TRUE)
rows=apply(raw,1,function(r){prod(as.numeric(!is.na(r)))>0})
realres=as.tbl(raw[rows,])
countries = readOGR(paste0(Sys.getenv('CN_HOME'),'/Models/MesoCoevol/analysis/gis'),'countries');country = countries[countries$CNTR_ID=="FR",];datapoints = SpatialPoints(data.frame(realres[,c("lonmin","latmin")]),proj4string = countries@proj4string)
selectedpoints = gContains(country,datapoints,byid = TRUE)
sdata = realres[selectedpoints,]
#rm(raw,realres);gc()

sdata=sdata[apply(sdata,1,function(r){prod(as.numeric(!is.na(r)))>0}),]
cdata=sdata[,c("meanBetweenness","meanPathLength","meanCloseness","networkPerf","diameter")]

for(j in 1:ncol(cdata)){cdata[,j]<-(cdata[,j]-min(cdata[,j]))/(max(cdata[,j])-min(cdata[,j]))}

# pca real data
#  -> real data is much richer
pcareal=prcomp(cdata)
cdata=as.tbl(cbind(data.frame(cdata),data.frame(as.matrix(data.frame(cdata))%*%pcareal$rotation)))

pcareal;summary(pcareal)

g=ggplot(cdata,aes(x=PC1,y=PC2))
g+geom_point()+stdtheme
ggsave(paste0(resdir,'real_pca.png'),width=20,height=20,units = 'cm')


###
# pca all with grids

ngrids = gridcaracs[,c("meanBetweenness","meanPathLength","meanCloseness")]
for(j in 1:ncol(ngrids)){ngrids[,j]<-(ngrids[,j]-min(ngrids[,j]))/(max(ngrids[,j])-min(ngrids[,j]))}
colnames(ngrids)<-c("meanBwCentrality","meanPathLength","meanClosenessCentrality")

full=as.tbl(rbind(
  data.frame(nres[,c("id","densityConf","meanBwCentrality","meanPathLength","meanClosenessCentrality","heuristic","morpho")]),
  data.frame(id=rep(NA,nrow(ngrids)),densityConf=rep(NA,nrow(ngrids)),meanBwCentrality=ngrids$meanBwCentrality,meanPathLength=ngrids$meanPathLength,meanClosenessCentrality=ngrids$meanClosenessCentrality,heuristic=rep('real',nrow(ngrids)),morpho=gridcaracs$cluster)
))
  

pcafull = prcomp(full[,3:5])
pcafull;summary(pcafull)
full=as.tbl(cbind(data.frame(full),data.frame(as.matrix(full[,3:5])%*%pcafull$rotation)))

g=ggplot(full[full$heuristic!='real',],aes(x=PC1,y=PC2,color=heuristic))
g+geom_point(size=0.5,alpha=0.8)+geom_point(data=full[full$heuristic=='real',],color='red')+ guides(colour = guide_legend(override.aes = list(size=5)))+stdtheme
ggsave(paste0(resdir,'feasible_space_withreal_pca.png'),width=21,height=18,units = 'cm')

g=ggplot(full[full$heuristic!='real',],aes(x=PC1,y=PC2,color=heuristic))
g+geom_point(size=0.5,alpha=0.8)+geom_point(data=full[full$heuristic=='real',],color='red')+facet_wrap(~morpho)+
  guides(colour = guide_legend(override.aes = list(size=5)))+stdtheme+theme(legend.position = c(0.8,0.2))
ggsave(paste0(resdir,'feasible_space_withreal_pca_bymorph.png'),width=30,height=21,units = 'cm')


###
# distrib of distances to real of the given grid
dngrids=data.frame(ngrids)
realvals=t(apply(data.frame(nres),1,function(r){unlist(dngrids[as.numeric(r[2]),])}))
realdists=sqrt(rowSums((nres[,3:5]-realvals)^2))

nres$distance = realdists

g=ggplot(nres,aes(x=distance,color=heuristic))
g+geom_density()+geom_vline(data=nres%>%group_by(heuristic)%>%summarise(distance=mean(distance)),aes(xintercept=distance,color=heuristic),linetype=2)+
  geom_vline(data=nres%>%group_by(heuristic)%>%summarise(distance=min(distance)),aes(xintercept=distance,color=heuristic),linetype=1)+
  stdtheme
ggsave(paste0(resdir,'distance_real.png'),width=21,height=18,units = 'cm')

nres%>%group_by(heuristic)%>%summarise(distance=min(distance))
nres%>%group_by(heuristic)%>%summarise(distance=mean(distance))
nres%>%group_by(heuristic)%>%summarise(distance=median(distance))


g=ggplot(nres,aes(x=distance,color=heuristic))
g+geom_density()+geom_vline(data=nres%>%group_by(heuristic,morpho)%>%summarise(distance=mean(distance)),aes(xintercept=distance,color=heuristic),linetype=2)+
  geom_vline(data=nres%>%group_by(heuristic,morpho)%>%summarise(distance=min(distance)),aes(xintercept=distance,color=heuristic),linetype=1)+
  facet_wrap(~morpho)+stdtheme+theme(legend.position = c(0.8,0.2))
ggsave(paste0(resdir,'distance_real_bymorph.png'),width=21,height=18,units = 'cm')



#   *     *
#      *









