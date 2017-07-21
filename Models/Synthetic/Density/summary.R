
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
sres$alpha = cut_interval(sres$alphalocalization,n=10)
sres$beta = cut_interval(sres$diffusion,n=10)
sres$rate_discr = cut_number(sres$rate,n=5)

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


## targeted plots
d = sres[sres$diffusionsteps==1&as.character(sres$rate_discr)=="(13.7,26.6]",]
g=ggplot(d,aes(x=alphalocalization,y=slope,color=beta))
g+geom_point(pch=".")+stat_smooth(span = 0.3)+xlab("alpha")+ylim(c(-1.2,0.0))+stdtheme+guides(colour=F)
ggsave(file=paste0(resdir,'slope_alpha_diffsteps1_rate13-26.png'),width=15,height=10,units = 'cm')
g=ggplot(d,aes(x=alphalocalization,y=distance,color=beta))
g+geom_point(pch=".")+stat_smooth(span = 0.3)+xlab("alpha")+stdtheme+guides(colour=F)
ggsave(file=paste0(resdir,'distance_alpha_diffsteps1_rate13-26.png'),width=15,height=10,units = 'cm')



d = sres[sres$diffusionsteps==4&as.character(sres$rate_discr)=="(41,78.4]",]
g=ggplot(d,aes(x=alphalocalization,y=slope,color=beta))
g+geom_point(pch=".")+stat_smooth(span = 0.4)+xlab("alpha")+stdtheme
ggsave(file=paste0(resdir,'slope_alpha_diffsteps4_rate41-78.png'),width=19,height=10,units = 'cm')
g=ggplot(d,aes(x=alphalocalization,y=distance,color=beta))
g+geom_point(pch=".")+stat_smooth(span = 0.4)+xlab("alpha")+stdtheme
ggsave(file=paste0(resdir,'distance_alpha_diffsteps4_rate41-78.png'),width=19,height=10,units = 'cm')


############
# histograms

# with LHS explo

res$alpha = cut_interval(res$alphalocalization,n=10)
res$beta = cut_interval(res$diffusion,n=10)
res$rate=res$population/res$growthrate
res$rate_discr = cut_number(res$rate,n=5)
res$diffsteps = floor(res$diffusionsteps)

res%>%group_by(alpha,beta,rate_discr,diffsteps)%>%summarise(count=n())

res$discrid = paste0(res$alpha,res$beta,res$rate_discr,res$diffsteps) 

g=ggplot(res[res$diffsteps==1&res$diffusion>0.45&res$rate>78.4,],aes(x=moran,fill=alpha))
g+geom_density(alpha=0.2)+stdtheme#+facet_grid(beta~rate_discr,scales = "free")

g=ggplot(res[res$diffsteps==4&res$diffusion>0.45&res$rate>78.4,],aes(x=moran,fill=alpha))
g+geom_density(alpha=0.2)+stdtheme#+facet_grid(beta~rate_discr,scales = "free")

# with targeted explo
res = as.tbl(read.csv('res/2017_07_14_08_47_47_REPLICATION_LOCAL.csv',sep=','))

resdir = resdir=paste0(Sys.getenv('CN_HOME'),'/Results/Synthetic/Density/20170714_Replication/')

res[,"growthrate/steps"]=paste0(res$growthrate,'/',res$diffusionsteps)
g=ggplot(res,aes_string(x="moran",fill="`growthrate/steps`"))
g+geom_density(alpha=0.4)+facet_grid(diffusion~alphalocalization,scales='free')+stdtheme
ggsave(file=paste0(resdir,'hist_moran.png'),width=30,height=20,units = 'cm')

g=ggplot(res,aes_string(x="distance",fill="`growthrate/steps`"))
g+geom_density(alpha=0.4)+facet_grid(diffusion~alphalocalization,scales='free')+stdtheme
ggsave(file=paste0(resdir,'hist_distance.png'),width=30,height=20,units = 'cm')

g=ggplot(res,aes_string(x="entropy",fill="`growthrate/steps`"))
g+geom_density(alpha=0.4)+facet_grid(diffusion~alphalocalization,scales='free')+stdtheme
ggsave(file=paste0(resdir,'hist_entropy.png'),width=30,height=20,units = 'cm')

g=ggplot(res,aes_string(x="slope",fill="`growthrate/steps`"))
g+geom_density(alpha=0.4)+facet_grid(diffusion~alphalocalization,scales='free')+stdtheme
ggsave(file=paste0(resdir,'hist_slope.png'),width=30,height=20,units = 'cm')

# values of sigma
sres = res %>% group_by(id) %>% summarise(
  meanMoran=mean(moran),sdMoran=sd(moran),sharpeMoran = mean(moran)/sd(moran),
  meanSlope=mean(slope),sdSlope=sd(slope),sharpeSlope = abs(mean(slope)/sd(slope)),
  meanEntropy=mean(entropy),sdEntropy=sd(entropy),sharpeEntropy = mean(entropy)/sd(entropy),
  meanDistance=mean(distance),sdDistance=sd(distance),sharpeDistance = mean(distance)/sd(distance)
)
summary(sres)


#########

res = as.tbl(read.csv(paste0(Sys.getenv("CN_HOME"),'/Results/Synthetic/Density/20151110_GridLHS/2015_11_10_18_11_05_GRID_LHS.csv'),sep=','))

resdir=paste0(Sys.getenv('CN_HOME'),'/Results/Synthetic/Density/20151110_GridLHS/')


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
g+geom_point()+stdtheme
ggsave(file=paste0(resdir,'pc_colbeta.png'),width=14.6,height=12,units='in',dpi = 300)

g=ggplot(sres,aes(x=PC1,y=PC2,colour=alpha))
g+geom_point()+stdtheme
ggsave(file=paste0(resdir,'pc_colalpha.png'),width=14.6,height=12,units='in',dpi = 300)


g=ggplot(sres,aes(x=PC1,y=PC2))
g+geom_point(pch='.')+geom_point(data=real,aes(x=PC1,y=PC2),colour='red',pch='.')
ggsave(file=paste0(resdir,'calib.png'),width=21,height=20,units='cm')

png(filename = paste0(resdir,'scatter.png'),width = 20,height=20,units = 'cm',res = 600)
plot(rbind(sres[,c("moran","slope","entropy","distance")],real[,c("moran","slope","entropy","distance")]),col=c(rep(rgb(0,0,0,0.2),nrow(sres)),rep(rgb(1,0,0,0.2),nrow(real))),pch='.')
dev.off()

# particular points
source(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations/morpho.R'))
rasterfile=paste0(Sys.getenv('CN_HOME'),'/Data/PopulationDensity/raw/popu01clcv5.tif')
# reprojected raster ? -> ok, same cells !

# calib 1 :
d=sqrt((real$moran-0.020)^2+(real$entropy-0.912)^2+(real$slope+0.617)^2+(real$distance-0.926)^2)
data.frame(real[d==min(d),])
xcor=33701;ycor=17401
getCoordinates(rasterfile,xcor,ycor)
matrix(c(moran=0.020,distance=0.926,entropy=0.912,slope=-0.617),nrow=1)%*%rot
# real : PC1 = 0.9544645 ; PC2 = 0.3296364 ; coordinates : -2.607152,39.74274 - Spain, Castilla-La Mancha, Cuenca
# synth : PC1 = 0.9487267 PC2 = 0.3245882 ; beta=0.108 ; NG=637 ; nd=1 ; alpha=1.14 ; population=13235.648362769914

# calib 2 :
d=sqrt((real$moran-0.014)^2+(real$entropy-0.63)^2+(real$slope+0.614)^2+(real$distance-0.776)^2)
data.frame(real[d==min(d),])
xcor=4601;ycor=36001
getCoordinates(rasterfile,xcor,ycor)
matrix(c(moran=0.014,distance=0.776,entropy=0.63,slope=-0.614),nrow=1)%*%rot
# real : PC1 = 0.7004772 ; PC2 = 0.2195029 ; coordinates : 27.16068,65.889 - Finland, Lapland
# synth :  PC1 = 0.6870686 ; PC2 = 0.2287785 ; beta=0.0060 ; NG=25 ; nd=1 ; alpha=0.4 ; population=849.895449367323


# calib 3 : 
d=sqrt((real$moran-0.1087)^2+(real$entropy-0.9405)^2+(real$slope+0.413)^2+(real$distance-0.8862)^2)
data.frame(real[d==min(d),])
xcor=32001;ycor=17701
getCoordinates(rasterfile,xcor,ycor)
matrix(c(moran=0.1087,distance=0.8862,entropy=0.9405,slope=-0.413),nrow=1)%*%rot
# real : PC1 = 1.017064 ; PC2 = 0.3510089 ; coordinates : -2.561874,41.30203 - Spain, Castilla et Leon, Soria
# synth : PC1 = 1.005976 PC2 = 0.3950987 ; beta=0.166; NG=100;nd=1;alpha=1;population=10017.238452906771

# calib 4 :
# PC1 0, PC2 0.6
d=sqrt((sres$PC1)^2+(sres$PC2-0.6)^2)
data.frame(sres[d==min(d),])
matrix(c(moran=0.14263,distance=0.2194,entropy=0.7156,slope=-1.5606),nrow=1)%*%rot
d=sqrt((real$moran-0.14263)^2+(real$entropy-0.7156)^2+(real$slope+1.5606)^2+(real$distance-0.2194)^2)
data.frame(real[d==min(d),])
xcor=36801;ycor=48801
d=sqrt((real$PC1)^2+(real$PC2-0.6)^2)
data.frame(real[d==min(d),])
xcor=27801;ycor=40601;getCoordinates(rasterfile,xcor,ycor)
# real : PC1 = -0.00177 ; PC2 = 0.6006739 ; coordinates : 25.7361,44.69989 - Romania, Bucharest
# synth : PC1 = -0.0543461 PC2 = 0.5798307 ; beta=0.432;NG=1273;nd=4;alpha=3.87;population=63024.359885979036


#################

# extract the real configurations

conf=extractSubRaster(rasterfile,r = xcor ,c=ycor,size=500,factor = 0.2)
write.table(conf,file=paste0('conf/x',xcor,'y',ycor,'.csv'),row.names = F,col.names = F,sep=';')




# -- Tests --

#
#  most right in synth point cloud
dr=data.frame(real[real$PC1==max(real$PC1[real$PC2>0.3]),])
xcor=32210;ycor=18701

#d=sqrt((sres$PC1-1.089513)^2+(sres$PC2-0.3292966)^2)
#d=sqrt((sres$moran-dr$moran)^2+(sres$entropy-dr$entropy)^2+(sres$slope-dr$slope)^2+(sres$distance-dr$distance)^2)
#d=sqrt((morph$moran[1:nrow(sres)]-dr$moran)^2+(morph$entropy[1:nrow(sres)]-dr$entropy)^2+(morph$slope[1:nrow(sres)]-dr$slope)^2+(morph$distance[1:nrow(sres)]-dr$distance)^2)
data.frame(sres[d==min(d),])

# most bottom left
data.frame(real[real$PC1<(-0.25)&real$PC2<0.15,])
xcor=5901;ycor=30101

d=sqrt((sres$PC1+0.2623876)^2+(sres$PC2-0.1330301)^2)
data.frame(sres[d==min(d),])

# top point
data.frame(real[real$PC2==max(real$PC2),])

# max moran
data.frame(real[real$moran==max(real$moran),])
xcor = 21001;ycor=21101
d=sqrt((sres$moran-0.2409049)^2+(sres$entropy-0.889)^2+(sres$slope+1.99)^2+(sres$distance-0.676)^2)
data.frame(sres[d==min(d),])


