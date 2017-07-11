
setwd(paste0(Sys.getenv("CN_HOME"),'/Models/Synthetic/Density'))

library(ggplot2)
library(dplyr)

stdtheme= theme(axis.title = element_text(size = 22), 
                axis.text.x = element_text(size = 15),axis.text.y = element_text(size = 15),
                strip.text = element_text(size=15),
                legend.text=element_text(size=15), legend.title=element_text(size=15))



res = as.tbl(read.csv(paste0(Sys.getenv("CN_HOME"),'/Results/Synthetic/Density/20151110_GridLHS/2015_11_10_18_11_05_GRID_LHS.csv'),sep=','))

sres = res %>% group_by(id) %>% summarise(
  diffusion=mean(diffusion),diffusionsteps=floor(mean(diffusionsteps)),alphalocalization=mean(alphalocalization),growthrate=mean(growthrate),population=mean(population),rate=mean(population)/mean(growthrate),
  moran=mean(moran),distance=mean(distance),entropy=mean(entropy),slope=mean(slope)
)


# discretize some parameters for facetting
sres$alpha = cut_interval(pcres$alphalocalization,n=10)
sres$beta = cut_interval(pcres$diffusion,n=10)
sres$rate_discr = cut_number(pcres$rate,n=5)

resdir=paste0(Sys.getenv('CN_HOME'),'/Results/Synthetic/Density/20151110_GridLHS/')

g=ggplot(sres,aes(x=alphalocalization,y=slope,color=beta))
g+geom_point(pch=".")+geom_smooth()+facet_grid(diffusionsteps~rate_discr)+xlab("alpha")+stdtheme
ggsave(file=paste0(resdir,'slope_alpha.png'),width=30,height=20,units = 'cm')

g=ggplot(sres,aes(x=diffusion,y=slope,color=alpha))
g+geom_point(pch=".")+geom_smooth()+facet_grid(diffusionsteps~rate_discr)+xlab("beta")+stdtheme
ggsave(file=paste0(resdir,'slope_beta.png'),width=30,height=20,units = 'cm')

g=ggplot(sres,aes(x=alphalocalization,y=moran,color=beta))
g+geom_point(pch=".")+geom_smooth()+facet_grid(diffusionsteps~rate_discr)+xlab("alpha")+stdtheme
ggsave(file=paste0(resdir,'moran_alpha.png'),width=30,height=20,units = 'cm')

g=ggplot(sres,aes(x=diffusion,y=moran,color=alpha))
g+geom_point(pch=".")+geom_smooth()+facet_grid(diffusionsteps~rate_discr)+xlab("beta")+stdtheme
ggsave(file=paste0(resdir,'moran_beta.png'),width=30,height=20,units = 'cm')

g=ggplot(sres,aes(x=alphalocalization,y=entropy,color=beta))
g+geom_point(pch=".")+geom_smooth()+facet_grid(diffusionsteps~rate_discr)+xlab("alpha")+stdtheme
ggsave(file=paste0(resdir,'entropy_alpha.png'),width=30,height=20,units = 'cm')

g=ggplot(sres,aes(x=diffusion,y=entropy,color=alpha))
g+geom_point(pch=".")+geom_smooth()+facet_grid(diffusionsteps~rate_discr)+xlab("beta")+stdtheme
ggsave(file=paste0(resdir,'entropy_beta.png'),width=30,height=20,units = 'cm')

g=ggplot(sres,aes(x=alphalocalization,y=distance,color=beta))
g+geom_point(pch=".")+geom_smooth()+facet_grid(diffusionsteps~rate_discr)+xlab("alpha")+stdtheme
ggsave(file=paste0(resdir,'distance_alpha.png'),width=30,height=20,units = 'cm')

g=ggplot(sres,aes(x=diffusion,y=distance,color=alpha))
g+geom_point(pch=".")+geom_smooth()+facet_grid(diffusionsteps~rate_discr)+xlab("beta")+stdtheme
ggsave(file=paste0(resdir,'distance_beta.png'),width=30,height=20,units = 'cm')


#########

sres = res %>% group_by(id) %>% summarise(
  beta=mean(diffusion),diffusionsteps=floor(mean(diffusionsteps)),alpha=mean(alphalocalization),growthrate=mean(growthrate),population=mean(population),rate=mean(population)/mean(growthrate),
  moran=mean(moran),distance=mean(distance),entropy=mean(entropy),slope=mean(slope)
)

real_raw = as.tbl(read.csv(paste0(Sys.getenv("CN_HOME"),'/Results/StaticCorrelations/Morphology/Density/Numeric/20150806_europe50km_10kmoffset_100x100grid.csv'),sep=";"))
real=real_raw[!is.na(real_raw[,3])&!is.na(real_raw[,4])&!is.na(real_raw[,5])&!is.na(real_raw[,6])&!is.na(real_raw[,7])&!is.na(real_raw[,8])&!is.na(real_raw[,9]),]


morph=rbind(sres[,c("moran","distance","entropy","slope")],real[,c("moran","distance","entropy","slope")])
for(j in 1:ncol(morph)){morph[,j]=(morph[,j]-min(morph[,j]))/(max(morph[,j])-min(morph[,j]))}

pr <- prcomp(morph);
rot=pr$rotation
pcsynth = as.tbl(data.frame(as.matrix(sres[,c("moran","distance","entropy","slope")])%*%pr$rotation))
sres=cbind(sres,pcsynth)

pcreal = as.tbl(data.frame(as.matrix(real[,c("moran","distance","entropy","slope")])%*%pr$rotation))
real=cbind(real,pcreal)

g=ggplot(sres,aes(x=PC1,y=PC2,colour=beta))
g+geom_point(pch='.')


g=ggplot(sres,aes(x=PC1,y=PC2))
g+geom_point(pch='.')+geom_point(data=real,aes(x=PC1,y=PC2),colour='red',pch='.')
ggsave(file=paste0(resdir,'calib.png'),width=21,height=20,units='cm')

# particular points
source(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations/morpho.R'))

#
# 1) most right in synth point cloud
dr=data.frame(real[real$PC1==max(real$PC1[real$PC2>0.3]),])
xcor=32210;ycor=18701
conf=extractSubRaster(paste0(Sys.getenv('CN_HOME'),'/Data/PopulationDensity/raw/popu01clcv5.tif'),r = xcor ,c=ycor,size=500,factor = 0.2)
write.table(conf,file=paste0('conf/x',xcor,'y',ycor,'.csv'),row.names = F,col.names = F,sep=';')

#d=sqrt((sres$PC1-1.089513)^2+(sres$PC2-0.3292966)^2)
#d=sqrt((sres$moran-dr$moran)^2+(sres$entropy-dr$entropy)^2+(sres$slope-dr$slope)^2+(sres$distance-dr$distance)^2)
d=sqrt((morph$moran[1:nrow(sres)]-dr$moran)^2+(morph$entropy[1:nrow(sres)]-dr$entropy)^2+(morph$slope[1:nrow(sres)]-dr$slope)^2+(morph$distance[1:nrow(sres)]-dr$distance)^2)
data.frame(sres[d==min(d),])

# 2) most bottom left
data.frame(real[real$PC1<(-0.25)&real$PC2<0.15,])
xcor=5901;ycor=30101
conf=extractSubRaster(paste0(Sys.getenv('CN_HOME'),'/Data/PopulationDensity/raw/popu01clcv5.tif'),r = xcor ,c=ycor,size=100,factor = 1)
write.table(conf,file=paste0('conf/x',xcor,'y',ycor,'.csv'),row.names = F,col.names = F,sep=';')

d=sqrt((sres$PC1+0.2623876)^2+(sres$PC2-0.1330301)^2)
data.frame(sres[d==min(d),])

# 3) top point
data.frame(real[real$PC2==max(real$PC2),])




