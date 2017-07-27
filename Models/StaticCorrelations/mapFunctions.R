
# mapping functions

#'
#'
loadIndicatorData<-function(file){
  if(extension(file)=='.csv'){
    raw=read.csv(file=file,sep=";",header=TRUE)
    rows=apply(raw,1,function(r){prod(as.numeric(!is.na(r[c(1,2)])))>0})
    return(as.tbl(raw[rows,]))
  }
  if(extension(file)=='.RData'){
    load(file)
    fullres = res[which(sapply(res,length)>1)];rm(res);gc()
    nonares = fullres[which(sapply(fullres,function(l){length(which(is.na(l)))})<29)];rm(fullres);gc()
    resdf = data.frame(matrix(unlist(nonares),nrow=length(nonares),byrow = T))
    names(resdf)<-c('lonmin','latmin',names(nonares[[1]])[3:length(nonares[[1]])])
    return(as.tbl(resdf))
  }
}



#y=function(x){log(x+0.01)};yinv = function(y){exp(y)-0.01}


map<-function(indiccols,filename,width,height,mfrow,mar=c(2,2.5,1.5,2) + 0.1,sdata=sdata){
  png(file=paste0(resdir,filename),width=width,height=height,units='cm',res=600)
  par(mfrow=mfrow ,mar = mar,
      oma = c(0,0,0,1) + 0.1)
  cols <- carto.pal(pal1 = "green.pal",n1 = 5, pal2 = "red.pal",n2 = 5)
  for(indic in indiccols){
    #x = y(unlist(sdata[,indic]))
    x = unlist(sdata[,indic])
    m=acast(data.frame(sdata[,c(1,2)],x),latmin~lonmin);r = raster(m[seq(from=nrow(m),to=1,by=-1),])
    crs(r)<-"+proj=longlat +datum=WGS84";extent(r)<-c(min(sdata$lonmin),max(sdata$lonmin),min(sdata$latmin),max(sdata$latmin))
    breaks=classIntervals(x,10)
    #ticks = yinv(seq(round(minValue(r),digits=1),round(maxValue(r),digits=1), round((round(maxValue(r),digits=2) - round(minValue(r),digits=2))/5,digits=1)))
    ticks = seq(round(minValue(r),digits=1),round(maxValue(r),digits=1), round((round(maxValue(r),digits=2) - round(minValue(r),digits=2))/5,digits=1))
    plot(r,main=colnames(sdata)[indic],
         col=cols,breaks=unique(breaks$brks),
         legend.width = 1.5,
         axis.args=list(at=ticks,labels=ticks,cex.axis=1.0)
    )
  }
  dev.off()
}

