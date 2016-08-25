
library(raster)
library(ggplot2)
library(dplyr)


# various functions

#'
#' converts a dataframe with two first columns coords into a raster (value third col)
dfToRaster <-function(d,column=3,normalize=FALSE){
  d=d[!is.na(d[,3]),]
  r=raster(SpatialPixels(SpatialPoints(d[,c(1,2)])))
  vals = d[,column]
  #show(length(vals))
  #show(ncell(r))
  if(normalize==TRUE){vals=(vals-min(vals))/(max(vals)-min(vals))}
  return(setValues(r,vals,index=cellFromXY(r,d[,c(1,2)])))
}



#'
#' compute cross correlations between two set of cols
#'
crossCorrelations<-function(m,c1,c2,f=function(x,y){return(cor(x,y))}){
  res = matrix(0,length(c1),length(c2))
  for(i in 1:length(c1)){
    for(j in 1:length(c2)){
      res[i,j]=f(m[,c1[i]],m[,c2[j]])
    }
  }
  return(res)
}



#'
#'
getCorrMatrices<-function(xcors,ycors,xyrhoasize,res,f=function(m){cor(m[,c(-1,-2)])}){
  corrs=list()
  for(i in 1:length(xcors)){
    corrs[[i]]=list()
    show(i)
    for(j in 1:length(ycors)){
      # compute correlation matrix ?
      x=xcors[i];y=ycors[j]
      rows = abs(res[,1]-x)<xyrhoasize/2&abs(res[,2]-y)<xyrhoasize/2
      rho = f(matrix(NA,nrow(res),ncol(res)))
      #show(length(which(rows)))
      if(length(which(rows))>10){# arbitrary threshold to have a minimal quantity of measures
        #show(res[rows,c(-1,-2)])
        #rho = cor(res[rows,c(-1,-2)])
        rho = f(res[rows,])
        #show(rho)
        #corrs[[i]][[j]]=rho
      }
      corrs[[i]][[j]]=rho
    }
  }
  return(corrs)
}


#'
#'
getCorrMeasure<-function(xcors,ycors,corrs,f){
  res = matrix(0,length(xcors)*length(ycors),3)
  k=1
  for(i in 1:length(xcors)){
    show(i)
    for(j in 1:length(ycors)){
      x=xcors[i];y=ycors[j]
      res[k,1:2]=c(x,y)
      res[k,3]=f(corrs[[i]][[j]])
      k=k+1
    }
  }
  return(res)
}


#'
#' compute correlation with confidence intervals
#' remove two first columns assumed as coordinates
corrTest<-function(m){
  m = m[,c(-1,-2)]
  est=matrix(1,ncol(m),ncol(m))
  mi=matrix(1,ncol(m),ncol(m))
  ma=matrix(1,ncol(m),ncol(m))
  for(i in 1:(ncol(m)-1)){
    for(j in (i+1):ncol(m)){
      tt=cor.test(m[,i],m[,j])
      est[i,j]=tt$estimate;mi[i,j]=tt$conf.int[1];ma[i,j]=tt$conf.int[2]
      est[j,i]=tt$estimate;mi[j,i]=tt$conf.int[1];ma[j,i]=tt$conf.int[2]
    }
  }
  return(list(estimate=est,conf.int.min=mi,conf.int.max=ma))
}





