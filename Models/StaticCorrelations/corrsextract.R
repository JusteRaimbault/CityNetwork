setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))
source('functions.R')
source('mapFunctions.R')

library(reshape2)

purpose='chinacoupled_areasize100_offset50_factor0.1_temp'
res=loadIndicatorData(paste0('res/',purpose,'.RData'))

rhoasizes=seq(from=4,to=20,by=4)

extrindex = 3

load(paste0('res/res/20170727_parallcorrs_',purpose,'.RData'))

corrs = parallcorrs[[extrindex]]$corrs
rhoasize = rhoasizes[extrindex]

istep=2;jstep=2;
xcors=sort(unique(res[,1]));xcors=xcors[seq(from=rhoasize/2,to=length(xcors)-(rhoasize/2),by=istep)]
ycors=sort(unique(res[,2]));ycors=ycors[seq(from=rhoasize/2,to=length(ycors)-(rhoasize/2),by=jstep)]
xstep=diff(xcors)[1];ystep=diff(ycors)[2]
xyrhoasize = xstep/istep*rhoasize

#save(corrs,file=paste0('res/res/20170727_parallcorrs_',purpose,'_rhoasize12.RData'))

arraycorrs=data.frame()
for(i in 1:length(xcors)){
  show(i)
  for(j in 1:length(ycors)){
    currentest = corrs[[i]][[j]]$estimate
    if(!is.null(dim(currenttest))){
      rownames(currentest)<-names(res)[c(-1,-2)];colnames(currentest)<-names(res)[c(-1,-2)]
      melted = melt(currentest);melted$names = paste0(as.character(melted[,1]),as.character(melted[,2]))
      row = data.frame(matrix(melted[,3],nrow=1,byrow=T));colnames(row)<-melted$names
      arraycorrs=rbind(arraycorrs,data.frame(xcor=xcors[i],ycor=ycors[j],row))
    }
  }
}

save(arraycorrs,file=paste0('res/res/20170727_dfcorrs_',purpose,'_rhoasize',rhoasize,'.RData'))







