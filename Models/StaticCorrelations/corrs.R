
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
raw=read.csv(file="res/res/europe_areasize100_offset50_factor0.5_20160824.csv",sep=";",header=TRUE)
rows=apply(raw,1,function(r){prod(as.numeric(!is.na(r)))>0})
res=raw[rows,]

# convert to raster ? not necessary if no use of focal (but better to plot !)

# coords where to compute correlations
#  -- steps must be here in number of measure square, not in pixels --

allcorrs=data.frame()
for(rhoasize in c(4,8,12)){
istep=4;jstep=4;rhoasize=4
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


load('res/res/sample4-8-12.RData')

dc = d[d$measure=='meanabs'&d$type=='cross',]%>%group_by(lat,lon)
dm = d[d$measure=='meanabs'&d$type=='morpho',]%>%group_by(lat,lon)
dn= d[d$measure=='meanabs'&d$type=='network',]%>%group_by(lat,lon)
dj = dc%>%inner_join(dm,by = c("lat","lon","delta"))%>%inner_join(dn,by = c("lat","lon","delta"))
g=ggplot(dj)
g+geom_point(aes(x=rho.x,y=rho.y,col=rho))+facet_wrap(~delta)+xlab("rho_cross")+ylab("rho_morpho")

#load('res/res/20160826_parallcorrs_corrTest_unlisted_nona_goodCols.RData')
#colnames(allcorrs)[4:5]=c("delta","type")
#allcorrs$rho=as.numeric(as.character(allcorrs$rho));allcorrs$lat=as.numeric(as.character(allcorrs$lat));allcorrs$lon=as.numeric(as.character(allcorrs$lon));allcorrs$delta=as.numeric(as.character(allcorrs$delta))
#allcorrs$type=as.character(allcorrs$type)
#colnames(allcorrs)<-c("lat","lon","rho","lat","lon","rhomin","lat","lon","rhomax","delta","type","measure")
#allcorrs=allcorrs[,c(1,2,3,6,9,10,11,12)]
#save(allcorrs,file='res/res/20160826_parallcorrs_corrTest_unlisted_nona_goodCols.RData')

#sumcorrs = as.tbl(allcorrs[allco,]) %>% group_by(delta,type) %>% summarise(meanrho=mean(rho,na.rm=TRUE),rhosd=sd(rho,na.rm=TRUE))

load('res/res/sumcorrs.RData')

g=ggplot(data.frame(sumcorrsmean,rhomin=sumcorrsmeanmin$meanrho,rhomax=sumcorrsmeanmax$meanrho),aes(x=delta,y=meanrho,color=type))
g+geom_point()+geom_errorbar(aes(ymin=meanrho-rhosd,ymax=meanrho+rhosd))+#geom_line(aes(x=delta,y=rhomin,group=type,col=type),linetype=2)+geom_line(aes(x=delta,y=rhomax,group=type,col=type),linetype=2)
  ylab("rho")

g+geom_line(aes(x=delta,y=(rhomax-rhomin)*delta,color=type))+ylab("|CI| x delta")

#par(mfrow=c(1,1))
#plot(sumcorrsmean$delta,sumcorrsmeanmax$meanrho-sumcorrsmeanmin$meanrho)

g=ggplot(allcorrs)
g+geom_density(aes(x=rho,col=type,linetype=as.factor(delta)),alpha=0.4)


# compare with stationary cor
fullcorr=getCorrMatrices(res[1,1],res[1,2],1000,res,f = corrTest)
getCorrMeasure(c(res[1,1]),c(res[1,2]),fullcorr,function(rho){diag(rho)<-0;return(mean(rho[1:7,8:20]))})
mean(fullcorr[[1]][[1]][1:7,1:7])
mean(fullcorr[[1]][[1]][8:20,8:20])
mean(fullcorr[[1]][[1]][1:7,8:20])
tt=cor.test(res[,3],res[,4])

#rpop=dfToRaster(raw,col=8);rpop=crop(rpop,extent(rmorph))

par(mfrow=c(2,2))
plot(rpop,main="pop");plot(rmorph,main="morpho");plot(rnet,main="network");plot(rcross,main="cross")

# plot indicators
#par(mfrow=c(4,5))
for(j in 3:22){plot(dfToRaster(raw,col=j),main=colnames(raw)[j])}

##
# pca analysis of corr matrices -> full matrix for now

#istep=2;jstep=2;#rhoasize=10

#save(corrs,file='res/res/corrstemp.RData')
#load('res/res/corrstemp.RData')

corrmat = matrix(data = unlist(corrs),ncol=400,byrow=TRUE)
rows=apply(corrmat,1,function(r){prod(as.numeric(!is.na(r)))>0})
corrmat = corrmat[rows,]
pca=prcomp(corrmat)
summary(pca)
rhopca = data.frame(getCorrMeasure(xcors,ycors,corrs,function(rho){if(!is.matrix(rho)){return(NA)};r=matrix(c(rho),ncol=length(rho))%*%as.matrix(pca$rotation);return(r[1,1])}))
colnames(rhopca)<-c("lat","lon","rho")

###
dd=d[d$measure=="meanabs",]
g=ggplot(dd)
#g=ggplot(rhopca)
g+geom_raster(aes(x=lat,y=lon,fill=rho))+scale_fill_gradient2(low="green",mid="white",high="brown",midpoint = median(dd$rho,na.rm=T))+#scale_fill_gradient2(low="#998ec3",mid="#f7f7f7",high="#f1a340")+#,midpoint = median(rhopca$rho,na.rm = T))+#scale_fill_gradient(low="yellow",high="red",name="PC1")+
  xlim(c(-11,32))+ylim(c(35.55,70))+facet_grid(type~delta)+ggtitle("Mean abs correlation")##+ggtitle("PCA (full matrix) ; delta = 4")#

# plot given area

#########

plots=list()
for(j in 3:22){
g=ggplot(res)
plots[[j-2]]=g+geom_raster(aes_string(x="lonmin",y="latmin",fill=colnames(res)[j]))+scale_fill_gradient2(low="blue",mid="white",high="red",midpoint = median(res[,j],na.rm = T))+ggtitle(colnames(res)[j])+xlab("")+ylab("")##+ggtitle("PCA (full matrix) ; delta = 4")#
#ggsave(paste0(Sys.getenv('CN_HOME'),'/Results/StaticCorrelations/20160824/indic_',colnames(res)[j],'.png'))
}
multiplot(plotlist = plots,cols = 5)

######
par(mfrow=c(4,5))
for(j in 3:22){
  hist(res[,j],breaks=1000,main=colnames(res)[j],xlab="")
}




