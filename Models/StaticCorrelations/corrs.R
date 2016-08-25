
####
#  Correlations
#

#  - extraction of spatial "stationarity scales" -> make the step vary
#  - algo for variable areas ?
#  - find "optimal" correlation scale ? (rho = f(scale), 
#       should vanish when increase - what behavior in small ? use correlation t-test (bof if vars not normal) ?
#       -> size of conf.int renormalized by n ?
#  - Q : link between stationarity and ergodicity ?
#  
#  Q : what measures of corr ? (indic by indic corrs ? Principal Components ? Spectral radius ? mean abs ? etc.)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))
source('functions.R')

library(raster)
library(ggplot2)
library(dplyr)

# load data
raw=read.csv(file="res/europe_areasize100_offset50_factor0.5_Mer-aoû-24-11:15:25-2016.csv",sep=";",header=TRUE)
rows=apply(raw,1,function(r){prod(as.numeric(!is.na(r)))>0})
res=raw[rows,]

# convert to raster ? not necessary if no use of focal (but better to plot !)

# coords where to compute correlations
#  -- steps must be here in number of measure square, not in pixels --

allcorrs=data.frame()
for(rhoasize in c(4,6,8,10,12,14)){
istep=2;jstep=2;#rhoasize=10
xcors=sort(unique(res[,1]));xcors=xcors[seq(from=rhoasize/2,to=length(xcors)-(rhoasize/2),by=istep)]
ycors=sort(unique(res[,2]));ycors=ycors[seq(from=rhoasize/2,to=length(ycors)-(rhoasize/2),by=jstep)]
xstep=diff(xcors)[1];ystep=diff(ycors)[2]
xyrhoasize = xstep/istep*rhoasize

corrs = getCorrMatrices(xcors,ycors,xyrhoasize,res)
#corrs = getCorrMatrices(xcors,ycors,xyrhoasize,res,function(m){crossCorrelations(m,3:9,10:22)})
# rq : far more slower with handmade cross-corr : better use built-in cor function and aggregate by projecting only on cross-cors


# test plotting mean abs corr
rhocross=getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho[1:7,8:20]))});colnames(rhocross)<-c("lat","lon","rho")
#rcross = dfToRaster(rhocross)
rhomorph=getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho[1:7,1:7]))});colnames(rhomorph)<-c("lat","lon","rho")
#rmorph = dfToRaster(rhomorph)
rhonet = getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho[8:20,8:20]))});colnames(rhonet)<-c("lat","lon","rho")
#rnet = dfToRaster(rhonet)
allcorrs=rbind(allcorrs,cbind(rhocross,rep(rhoasize,nrow(rhocross)),rep("cross",nrow(rhocross))))
allcorrs=rbind(allcorrs,cbind(rhomorph,rep(rhoasize,nrow(rhomorph)),rep("morpho",nrow(rhomorph))))
allcorrs=rbind(allcorrs,cbind(rhonet,rep(rhoasize,nrow(rhonet)),rep("network",nrow(rhonet))))
}
#save(allcorrs,file='res/res/20160824_allcorrs.RData')
load('res/res/20160824_allcorrs.RData')
colnames(allcorrs)[4:5]=c("delta","type")
allcorrs$rho=as.numeric(as.character(allcorrs$rho));allcorrs$lat=as.numeric(as.character(allcorrs$lat));allcorrs$lon=as.numeric(as.character(allcorrs$lon));allcorrs$delta=as.numeric(as.character(allcorrs$delta))
allcorrs$type=as.character(allcorrs$type)

sumcorrs = as.tbl(allcorrs) %>% group_by(delta,type) %>% summarise(meanrho=mean(rho,na.rm=TRUE),rhosd=sd(rho,na.rm=TRUE))

g=ggplot(sumcorrs,aes(x=delta,y=meanrho,color=type))
g+geom_line()+geom_point()+geom_errorbar(aes(ymin=meanrho-rhosd,ymax=meanrho+rhosd))+ylab("rho")

g=ggplot(allcorrs)
g+geom_density(aes(x=rho,col=type,linetype=as.factor(delta)),alpha=0.4)

#rpop=dfToRaster(raw,col=8);rpop=crop(rpop,extent(rmorph))

par(mfrow=c(2,2))
plot(rpop,main="pop");plot(rmorph,main="morpho");plot(rnet,main="network");plot(rcross,main="cross")

#
par(mfrow=c(4,5))
for(j in 3:22){plot(dfToRaster(raw,col=j),main=colnames(raw)[j])}

##
# pca analysis of corr matrices -> full matrix for now
corrmat = matrix(data = unlist(corrs),ncol=400,byrow=TRUE)
rows=apply(corrmat,1,function(r){prod(as.numeric(!is.na(r)))>0})
corrmat = corrmat[rows,]
pca=prcomp(corrmat)
summary(pca)
rhopca = data.frame(getCorrMeasure(xcors,ycors,corrs,function(rho){r=matrix(c(rho),ncol=length(rho))%*%as.matrix(pca$rotation);return(r[1,1])}))
colnames(rhopca)<-c("lat","lon","rho")

###
g=ggplot(allcorrs)
#g=ggplot(rhopca)
g+geom_raster(aes(x=lat,y=lon,fill=rho))+#scale_fill_gradient2(low="#998ec3",mid="#f7f7f7",high="#f1a340")+#,midpoint = median(rhopca$rho,na.rm = T))+#scale_fill_gradient(low="yellow",high="red",name="PC1")+
  xlim(c(-11,32))+ylim(c(35.55,70))+facet_grid(type~delta)#+ggtitle("PCA (full matrix)")

# plot given area



