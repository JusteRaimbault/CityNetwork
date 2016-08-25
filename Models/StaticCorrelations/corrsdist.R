
# computation of corrs as function of distance

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))
source('functions.R')

# load data
raw=read.csv(file="res/res/europe_areasize100_offset50_factor0.5_20160824.csv",sep=";",header=TRUE)
rows=apply(raw,1,function(r){prod(as.numeric(!is.na(r)))>0})
res=raw[rows,]


rhoasizes=4:83

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
  
  # means
  rhocross_est_mean=getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho$estimate[1:7,8:20]))})
  rhocross_inf_mean=getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho$conf.int.min[1:7,8:20]))})
  rhocross_sup_mean=getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho$conf.int.max[1:7,8:20]))})
  rhomorph_est_mean=getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho$estimate[1:7,1:7]))})
  rhomorph_inf_mean=getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho$conf.int.min[1:7,1:7]))})
  rhomorph_sup_mean=getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho$conf.int.max[1:7,1:7]))})
  rhonet_est_mean = getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho$estimate[8:20,8:20]))})
  rhonet_inf_mean = getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho$conf.int.min[8:20,8:20]))})
  rhonet_sup_mean = getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho$conf.int.max[8:20,8:20]))})
  
  # mean abs
  rhocross_est_meanabs=getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(abs(rho$estimate[1:7,8:20])))})
  rhocross_inf_meanabs=getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(abs(rho$conf.int.min[1:7,8:20])))})
  rhocross_sup_meanabs=getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(abs(rho$conf.int.max[1:7,8:20])))})
  rhomorph_est_meanabs=getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(abs(rho$estimate[1:7,1:7])))})
  rhomorph_inf_meanabs=getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(abs(rho$conf.int.min[1:7,1:7])))})
  rhomorph_sup_meanabs=getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(abs(rho$conf.int.max[1:7,1:7])))})
  rhonet_est_meanabs = getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(abs(rho$estimate[8:20,8:20])))})
  rhonet_inf_meanabs = getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(abs(rho$conf.int.min[8:20,8:20])))})
  rhonet_sup_meanabs = getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(abs(rho$conf.int.max[8:20,8:20])))})
  
  # store
  allcorrs=rbind(allcorrs,cbind(rhocross_est_mean,rhocross_inf_mean,rhocross_sup_mean,rep(rhoasize,nrow(rhocross_est_mean)),rep("cross",nrow(rhocross_est_mean)),rep("mean",nrow(rhocross_est_mean))))
  allcorrs=rbind(allcorrs,cbind(rhomorph_est_mean,rhomorph_inf_mean,rhomorph_sup_mean,rep(rhoasize,nrow(rhomorph)),rep("morpho",nrow(rhomorph)),rep("mean",nrow(rhocross_est_mean))))
  allcorrs=rbind(allcorrs,cbind(rhonet_est_mean,rhonet_inf_mean,rhonet_sup_mean,rep(rhoasize,nrow(rhonet)),rep("network",nrow(rhonet)),rep("mean",nrow(rhocross_est_mean))))
  allcorrs=rbind(allcorrs,cbind(rhocross_est_meanabs,rhocross_inf_meanabs,rhocross_sup_meanabs,rep(rhoasize,nrow(rhocross_est_mean)),rep("cross",nrow(rhocross_est_mean)),rep("meanabs",nrow(rhocross_est_mean))))
  allcorrs=rbind(allcorrs,cbind(rhomorph_est_meanabs,rhomorph_inf_meanabs,rhomorph_sup_meanabs,rep(rhoasize,nrow(rhomorph)),rep("morpho",nrow(rhomorph)),rep("meanabs",nrow(rhocross_est_mean))))
  allcorrs=rbind(allcorrs,cbind(rhonet_est_meanabs,rhonet_inf_meanabs,rhonet_sup_meanabs,rep(rhoasize,nrow(rhonet)),rep("network",nrow(rhonet)),rep("meanabs",nrow(rhocross_est_mean))))
  
  return(allcorrs)
}

save(parallcorrs,file='res/res/20160825_parallcorrs_corrTest.RData')

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

colnames(allcorrs)=c("lat","lon","rho","rhomin","rhomax","delta","type")
allcorrs$rho=as.numeric(as.character(allcorrs$rho));allcorrs$lat=as.numeric(as.character(allcorrs$lat));allcorrs$lon=as.numeric(as.character(allcorrs$lon));allcorrs$delta=as.numeric(as.character(allcorrs$delta))
allcorrs$type=as.character(allcorrs$type)

save(allcorrs,file='res/res/20160825_parallcorrs_corrTest_unlisted.RData')



