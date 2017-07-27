
# computation of corrs as function of distance

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))
source('functions.R')
source('mapFunctions.R')

# load data
#raw=read.csv(file="res/res/europe_areasize100_offset50_factor0.5_20160824.csv",sep=";",header=TRUE)
#rows=apply(raw,1,function(r){prod(as.numeric(!is.na(r)))>0})
#res=raw[rows,]
purpose='chinacoupled_areasize100_offset50_factor0.1_temp'
res=loadIndicatorData(paste0('res/',purpose,'.RData'))

#rhoasizes=4:83
rhoasizes=seq(from=4,to=20,by=4)

library(doParallel)
cl <- makeCluster(5,outfile='log')
registerDoParallel(cl)

parallcorrs <- foreach(rhoasize=rhoasizes) %dopar% {
  try({
  source('functions.R')
  allcorrs=data.frame()
  istep=2;jstep=2;
  xcors=sort(unique(res[,1]));xcors=xcors[seq(from=rhoasize/2,to=length(xcors)-(rhoasize/2),by=istep)]
  ycors=sort(unique(res[,2]));ycors=ycors[seq(from=rhoasize/2,to=length(ycors)-(rhoasize/2),by=jstep)]
  xstep=diff(xcors)[1];ystep=diff(ycors)[2]
  xyrhoasize = xstep/istep*rhoasize
  corrs = getCorrMatrices(xcors,ycors,xyrhoasize,res,f=corrTest)
  
  # means
  rhocross_est_mean=getCorrMeasure(xcors,ycors,corrs,function(rho){if(is.na(rho)){return(NA)};diag(rho$estimate)<-0;return(mean(rho$estimate[1:7,8:20]))})
  rhocross_inf_mean=getCorrMeasure(xcors,ycors,corrs,function(rho){if(is.na(rho)){return(NA)};diag(rho$conf.int.min)<-0;return(mean(rho$conf.int.min[1:7,8:20]))})
  rhocross_sup_mean=getCorrMeasure(xcors,ycors,corrs,function(rho){if(is.na(rho)){return(NA)};diag(rho$conf.int.max)<-0;return(mean(rho$conf.int.max[1:7,8:20]))})
  rhomorph_est_mean=getCorrMeasure(xcors,ycors,corrs,function(rho){if(is.na(rho)){return(NA)};diag(rho$estimate)<-0;return(mean(rho$estimate[1:7,1:7]))})
  rhomorph_inf_mean=getCorrMeasure(xcors,ycors,corrs,function(rho){if(is.na(rho)){return(NA)};diag(rho$conf.int.min)<-0;return(mean(rho$conf.int.min[1:7,1:7]))})
  rhomorph_sup_mean=getCorrMeasure(xcors,ycors,corrs,function(rho){if(is.na(rho)){return(NA)};diag(rho$conf.int.max)<-0;return(mean(rho$conf.int.max[1:7,1:7]))})
  rhonet_est_mean = getCorrMeasure(xcors,ycors,corrs,function(rho){if(is.na(rho)){return(NA)};diag(rho$estimate)<-0;return(mean(rho$estimate[8:20,8:20]))})
  rhonet_inf_mean = getCorrMeasure(xcors,ycors,corrs,function(rho){if(is.na(rho)){return(NA)};diag(rho$conf.int.min)<-0;return(mean(rho$conf.int.min[8:20,8:20]))})
  rhonet_sup_mean = getCorrMeasure(xcors,ycors,corrs,function(rho){if(is.na(rho)){return(NA)};diag(rho$conf.int.max)<-0;return(mean(rho$conf.int.max[8:20,8:20]))})

  show(rhocross_est_mean)
  show(rhomorph_est_mean)
  show(rhonet_est_mean)  

  # mean abs
  rhocross_est_meanabs=getCorrMeasure(xcors,ycors,corrs,function(rho){if(is.na(rho)){return(NA)};diag(rho$estimate)<-0;return(mean(abs(rho$estimate[1:7,8:20])))})
  rhocross_inf_meanabs=getCorrMeasure(xcors,ycors,corrs,function(rho){if(is.na(rho)){return(NA)};diag(rho$conf.int.min)<-0;return(mean(abs(rho$conf.int.min[1:7,8:20])))})
  rhocross_sup_meanabs=getCorrMeasure(xcors,ycors,corrs,function(rho){if(is.na(rho)){return(NA)};diag(rho$conf.int.max)<-0;return(mean(abs(rho$conf.int.max[1:7,8:20])))})
  rhomorph_est_meanabs=getCorrMeasure(xcors,ycors,corrs,function(rho){if(is.na(rho)){return(NA)};diag(rho$estimate)<-0;return(mean(abs(rho$estimate[1:7,1:7])))})
  rhomorph_inf_meanabs=getCorrMeasure(xcors,ycors,corrs,function(rho){if(is.na(rho)){return(NA)};diag(rho$conf.int.min)<-0;return(mean(abs(rho$conf.int.min[1:7,1:7])))})
  rhomorph_sup_meanabs=getCorrMeasure(xcors,ycors,corrs,function(rho){if(is.na(rho)){return(NA)};diag(rho$conf.int.max)<-0;return(mean(abs(rho$conf.int.max[1:7,1:7])))})
  rhonet_est_meanabs = getCorrMeasure(xcors,ycors,corrs,function(rho){if(is.na(rho)){return(NA)};diag(rho$estimate)<-0;return(mean(abs(rho$estimate[8:20,8:20])))})
  rhonet_inf_meanabs = getCorrMeasure(xcors,ycors,corrs,function(rho){if(is.na(rho)){return(NA)};diag(rho$conf.int.min)<-0;return(mean(abs(rho$conf.int.min[8:20,8:20])))})
  rhonet_sup_meanabs = getCorrMeasure(xcors,ycors,corrs,function(rho){if(is.na(rho)){return(NA)};diag(rho$conf.int.max)<-0;return(mean(abs(rho$conf.int.max[8:20,8:20])))})
  
  # store
  allcorrs=rbind(allcorrs,cbind(rhocross_est_mean,rhocross_inf_mean,rhocross_sup_mean,rep(rhoasize,nrow(rhocross_est_mean)),rep("cross",nrow(rhocross_est_mean)),rep("mean",nrow(rhocross_est_mean))))
  allcorrs=rbind(allcorrs,cbind(rhomorph_est_mean,rhomorph_inf_mean,rhomorph_sup_mean,rep(rhoasize,nrow(rhomorph_est_mean)),rep("morpho",nrow(rhomorph_est_mean)),rep("mean",nrow(rhomorph_est_mean))))
  allcorrs=rbind(allcorrs,cbind(rhonet_est_mean,rhonet_inf_mean,rhonet_sup_mean,rep(rhoasize,nrow(rhonet_est_mean)),rep("network",nrow(rhonet_est_mean)),rep("mean",nrow(rhonet_est_mean))))
  allcorrs=rbind(allcorrs,cbind(rhocross_est_meanabs,rhocross_inf_meanabs,rhocross_sup_meanabs,rep(rhoasize,nrow(rhocross_est_mean)),rep("cross",nrow(rhocross_est_mean)),rep("meanabs",nrow(rhocross_est_mean))))
  allcorrs=rbind(allcorrs,cbind(rhomorph_est_meanabs,rhomorph_inf_meanabs,rhomorph_sup_meanabs,rep(rhoasize,nrow(rhomorph_est_mean)),rep("morpho",nrow(rhomorph_est_mean)),rep("meanabs",nrow(rhomorph_est_mean))))
  allcorrs=rbind(allcorrs,cbind(rhonet_est_meanabs,rhonet_inf_meanabs,rhonet_sup_meanabs,rep(rhoasize,nrow(rhonet_est_mean)),rep("network",nrow(rhonet_est_mean)),rep("meanabs",nrow(rhonet_est_mean))))
  
  return(list(allcorrs=allcorrs,corrs=corrs))
  })
}

save(parallcorrs,file=paste0('res/res/20170727_parallcorrs_',purpose,'.RData'))

# do some unlisting and shit

# adjust types
#colnames(allcorrs)[4:5]=c("delta","type")
#allcorrs$rho=as.numeric(as.character(allcorrs$rho));allcorrs$lat=as.numeric(as.character(allcorrs$lat));allcorrs$lon=as.numeric(as.character(allcorrs$lon));allcorrs$delta=as.numeric(as.character(allcorrs$delta))
#allcorrs$type=as.character(allcorrs$type)

#allcorrs=data.frame()
#for(j in 1:length(parallcorrs)){
#  show(j)
#  allcorrs=rbind(allcorrs,parallcorrs[[j]])
#}

#colnames(allcorrs)=c("lat","lon","rho","rhomin","rhomax","delta","type")
#allcorrs$rho=as.numeric(as.character(allcorrs$rho));allcorrs$lat=as.numeric(as.character(allcorrs$lat));allcorrs$lon=as.numeric(as.character(allcorrs$lon));allcorrs$delta=as.numeric(as.character(allcorrs$delta))
#allcorrs$type=as.character(allcorrs$type)

#save(allcorrs,file='res/res/20160826_parallcorrs_corrTest_unlisted.RData')



