
# computation of corrs as function of distance

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))
source('functions.R')

# load data
raw=read.csv(file="res/europe_areasize100_offset50_factor0.5_20160824.csv",sep=";",header=TRUE)
rows=apply(raw,1,function(r){prod(as.numeric(!is.na(r)))>0})
res=raw[rows,]


rhoasizes=4:43

library(doParallel)
cl <- makeCluster(20,outfile='log')
registerDoParallel(cl)

parallcorrs <- foreach(rhoasize=rhoasizes) %dopar% {
  source('functions.R')
  allcorrs=data.frame()
  istep=2;jstep=2;
  xcors=sort(unique(res[,1]));xcors=xcors[seq(from=rhoasize/2,to=length(xcors)-(rhoasize/2),by=istep)]
  ycors=sort(unique(res[,2]));ycors=ycors[seq(from=rhoasize/2,to=length(ycors)-(rhoasize/2),by=jstep)]
  xstep=diff(xcors)[1];ystep=diff(ycors)[2]
  xyrhoasize = xstep/istep*rhoasize
  corrs = getCorrMatrices(xcors,ycors,xyrhoasize,res,f=corrTest)
  rhocross_est_mean=getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho$estimate[1:7,8:20]))})
  rhocross_inf_mean=getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho$conf.int.min[1:7,8:20]))})
  rhocross_sup_mean=getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho$conf.int.max[1:7,8:20]))})
  rhomorph_est_mean=getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho[1:7,1:7]))})
  rhonet = getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho[8:20,8:20]))})
  allcorrs=rbind(allcorrs,cbind(rhocross,rep(rhoasize,nrow(rhocross)),rep("cross",nrow(rhocross))))
  allcorrs=rbind(allcorrs,cbind(rhomorph,rep(rhoasize,nrow(rhomorph)),rep("morpho",nrow(rhomorph))))
  allcorrs=rbind(allcorrs,cbind(rhonet,rep(rhoasize,nrow(rhonet)),rep("network",nrow(rhonet))))
  return(allcorrs)
}

save(parallcorrs,file='res/res/20160825_parallcorrs.RData')

# do some unlisting and shit

# adjust types
#colnames(allcorrs)[4:5]=c("delta","type")
#allcorrs$rho=as.numeric(as.character(allcorrs$rho));allcorrs$lat=as.numeric(as.character(allcorrs$lat));allcorrs$lon=as.numeric(as.character(allcorrs$lon));allcorrs$delta=as.numeric(as.character(allcorrs$delta))
#allcorrs$type=as.character(allcorrs$type)

allcorrs=data.frame()
for(j in 1:length(parallcorrs)){
  show(j)
  allcorrs=rbind(allcorrs,parallcorrs[[j]])
}

colnames(allcorrs)=c("lat","lon","rho","delta","type")
allcorrs$rho=as.numeric(as.character(allcorrs$rho));allcorrs$lat=as.numeric(as.character(allcorrs$lat));allcorrs$lon=as.numeric(as.character(allcorrs$lon));allcorrs$delta=as.numeric(as.character(allcorrs$delta))
allcorrs$type=as.character(allcorrs$type)

save(allcorrs,file='res/res/20160825_parallcorrs_unlisted.RData')



