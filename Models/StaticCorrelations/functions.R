
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
#' @description compute correlation matrices, with a given function (use corrTest for estimates and confidence intervals)
#'      on square windows centered on (xcors)x(ycors), of size xyrhoasize (must be in coordinates units)
#'
getCorrMatrices<-function(xcors,ycors,xyrhoasize,res,f=function(m){ifelse(is.na(m),matrix(NA,ncol(res)-2,ncol(res)-2),cor(m[,c(-1,-2)]))}){
  corrs=list()
  for(i in 1:length(xcors)){
    corrs[[i]]=list()
    show(i)
    for(j in 1:length(ycors)){
      # compute correlation matrix ?
      x=xcors[i];y=ycors[j]
      rows = abs(res[,1]-x)<xyrhoasize/2&abs(res[,2]-y)<xyrhoasize/2
      rho = f(NA)
      #rho = matrix(NA,nrow(res)-2,ncol(res)-2)
      #show(length(which(rows)))
      #rho = list()#atrix(NA,(ncol(res)-2),(ncol(res)-2))
      #if(length(which(rows))>0){show(length(which(rows)))}
      if(length(which(rows))>10){# arbitrary threshold to have a minimal quantity of measures
        #show(res[rows,c(-1,-2)])
        rho = cor(res[rows,c(-1,-2)])
        #rho = f(res[rows,])
        #show(rho)
        #corrs[[as.character(i)]][[as.character(j)]]=rho
        corrs[[i]][[j]]=rho
      }
      #corrs[[i]][[j]]=rho
    }
  }
  return(corrs)
}


#'
#' @description given list of correlations matrices corrs, computes a function of this matrix at coordinates (xcors)x(ycors)
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
#' @description  compute correlation with confidence intervals
#    removes two first columns assumed as coordinates
corrTest<-function(m){
  if(is.na(m)){return(list(estimate=NA,conf.int.min=NA,conf.int.max=NA))}
  m = m[,c(-1,-2)]
  est=matrix(NA,ncol(m),ncol(m))
  mi=matrix(NA,ncol(m),ncol(m))
  ma=matrix(NA,ncol(m),ncol(m))
  tryCatch({
  for(i in 1:(ncol(m)-1)){
    for(j in (i+1):ncol(m)){
      if(length(which(is.na(m[,i])))<length(m[,i])-3&length(which(is.na(m[,j])))<length(m[,j])-3){
        tt=cor.test(m[,i],m[,j])
        est[i,j]=tt$estimate;mi[i,j]=tt$conf.int[1];ma[i,j]=tt$conf.int[2]
        est[j,i]=tt$estimate;mi[j,i]=tt$conf.int[1];ma[j,i]=tt$conf.int[2]
      }
    }
  }
  for(i in 1:ncol(m)){if(length(which(is.na(m[,i])))<length(m[,i])-3){est[i,i]=1.0;mi[i,i]=1.0;ma[i,i]=1.0}}
  },error=function(e){show(e);show(tt)})
  return(list(estimate=est,conf.int.min=mi,conf.int.max=ma))
}





getLinearModels<-function(yvar,vars,nvars){
  # brute force with enumerating all sets
  varsets =list(c())
  for(i in 1:nvars){
    newsets = list();j=1
    for(prevset in varsets){
      for(var in vars){
        newsets[[j]]=union(prevset,c(var));j=j+1
      }
    }
    k=1;varsets=list()
    for(j1 in 1:length(newsets)){
      toadd=TRUE
      if(length(varsets)>0){
        for(j2 in 1:length(varsets)){
          toadd=toadd&(!setequal(newsets[[j1]],varsets[[j2]]))
        }
      }
      if(toadd){varsets[[k]]=newsets[[j1]];k=k+1}
    }
    #show(varsets)
  }
  res=c()
  for(varset in varsets){
    if(length(varset)<=nvars){
      currentmodel=paste0(yvar,"~",varset[1])
      if(length(varset)>1){for(var in varset[2:length(varset)]){currentmodel=paste0(currentmodel,"+",var)}}
      res=append(res,currentmodel)
    }
  }
  return(res)
}







