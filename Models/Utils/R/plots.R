
######################
## Plotting Utils
######################


# function to get single param points from raw result
#  --> make generic function ?
getSingleParamPoints <- function(data,params_cols,indics_cols){
  
  # can be disordered -> need to fill a list and compute means,sd afterwards
  
  params = list();indics = list()
  pkeys = list();#hashlist to keep position of parameters in params,indics list
  for(l in 1:nrow(data)){
    if(l%%1000==0){show(l)}
    pval = data[l,params_cols]
    key = Reduce(paste0,apply(pval,1,as.character),"")
    if(is.null(pkeys[[key]])){
      params = append(params,list(pval))
      indics = append(indics,list(list(as.numeric(data[l,indics_cols]))))
      pkeys[[key]] = length(params) # necessarily last element of the list
    }else{
      ind = pkeys[[key]]
      indics[[ind]]=append(indics[[ind]], list(as.numeric(data[l,indics_cols])))
    }
  }
  
  return(
    list(
       param=params,
       mean=lapply(indics,function(ll){colMeans(matrix(unlist(ll),nrow=length(ll),byrow=TRUE))}),
       sd=lapply(indics,function(ll){apply(matrix(unlist(ll),nrow=length(ll),byrow=TRUE),2,sd)})
         )
   )
}



##
# given a param and indics means, must find representative closest to this centroid
# 
#
getRepresentatives<-function(raw_results,aggregated_results,
                             parameter_rows,
                             raw_params_cols,aggregated_params_cols,
                             raw_indics_cols,aggregated_indics_cols
){
  
  repres = matrix(0,length(parameter_rows),ncol(raw_results))
  r=1
  
  for(p in parameter_rows){
    show(p)
    values = raw_results[as.logical(apply(raw_results[,raw_params_cols]==kronecker(rep(1,nrow(raw_results)),as.matrix(aggregated_results[p,aggregated_params_cols])),1,prod)),]
    d=apply((values[,raw_indics_cols]-kronecker(rep(1,nrow(values)),as.matrix(aggregated_results[p,aggregated_indics_cols]))),1,function(x){sum(x^2)})
    #show(as.matrix(values[d==min(d)[1],]))
    repres[r,]=as.matrix(values[d==min(d)[1],])
    r=r+1
  }
  
  colnames(repres)<-colnames(res)
  
  return(repres)
  
}








# multiplot


## dirty dirty to handle multiplots with ggplot :(
# function from R cookbook
# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}




############################
# plot points
plotPoints<-function(d1,d2=NULL,xstring,ystring,colstring){
  p = ggplot(d1, aes_string(x=xstring,y=ystring,col=colstring))
  if(!is.null(d2)){
    return(p + geom_point() + geom_point(data=d2, aes_string(x = xstring, y = ystring),colour=I("red"),shape="+",size=5))
  }else{
    return(p + geom_point())
  }
}


##############
## normalization of columns
normalize<-function(m){
  res = matrix(m,nrow=nrow(m))
  for(j in 1:ncol(res)){res[,j]=(res[,j]-min(res[,j]))/(max(res[,j])-min(res[,j]))}
  return(res)
}




################
# Fitted histogram
#   plots hist with fitted distribution, of the given type.
#
fittedHist<-function(x,distribution,breaks=10,xlab="",main=""){
  
  
  
}













