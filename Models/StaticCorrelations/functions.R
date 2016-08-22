
# various functions

#'
#' converts a dataframe with two first columns coords into a raster (value third col)
dfToRaster <-function(d,column=3,normalize=FALSE){
  r=raster(SpatialPixels(SpatialPoints(d[,c(1,2)])))
  vals = d[,column]
  if(normalize==TRUE){vals=(vals-min(vals))/(max(vals)-min(vals))}
  return(setValues(r,vals,index=cellFromXY(r,d[,c(1,2)])))
}


#'
#'
getCorrMeasure<-function(xcors,ycors,corrs,f){
  res = matrix(0,length(xcors)*length(ycors),3)
  k=1
  for(x in xcors){
    for(y in ycors){
      res[k,1:2]=c(x,y)
      res[k,3]=f(corrs[[x]][[y]])
      k=k+1
    }
  }
  return(res)
}
