
####################
## Analysis of Morpho Analysis Calibration
####################

# setwd with env var : need Sys.getenv
setwd(paste0(Sys.getenv("CN_HOME"),'/Models/Synthetic/Density'))

# load result
res = read.csv('res/explo_04:50:49.122 PM 09-avr.-2015.csv',sep=';')

# function to get single param points from raw result
#  --> make generic function ?
getSingleParamPoints <- function(data,params_cols,indics_cols,nreps){
  # really more simple to use nreps
  # necessarily, length(data[,1])/nreps \in \mathbb{N}
  k = length(data[,1]) / nreps
  means = matrix(0,k,length(indics_cols))
  sigmas = matrix(0,k,length(indics_cols))
  params = matrix(0,k,length(params_cols))
 
  for(kk in 0:(k-1)){
    #show(points)
    d = data[((kk*nreps)+1):((kk+1)*nreps),indics_cols]
    means[kk+1,] = apply(d,2,mean);sigmas[kk+1,]=apply(d,2,sd)
    for(j in 1:length(indics_cols)){
      params[(kk+1),j] = data[((kk*nreps)+1),params_cols[j]]
    }
  }
  return(list(params,means,sigmas))
}


# test
p = getSingleParamPoints(res,1:4,5:8,20)

# ggplot

library(ggplot2)

# simple plot
m = data.frame(moran=p[[2]][,1],distance=p[[2]][,2],
               entropy=p[[2]][,3],slope=p[[2]][,4],
               diffusion=p[[1]][,1],diffsteps=p[[1]][,2],alpha=p[[1]][,3],rate=p[[1]][,4])
s = data.frame(moran=p[[3]][,1],distance=p[[3]][,2],entropy=p[[3]][,3],slope=p[[3]][,4])

# plotPoints<-function(data,xx,yy,sx,sy,col,with_bars){
#   p = ggplot(data, aes(x=xx,y=yy,col=col))
#   p + geom_point()
#   if(with_bars){
#     p + geom_errorbarh(aes(xmin=xx-sx, xmax=xx+sx), height=.005) +
#     geom_errorbar(aes(ymin=yy-sy, ymax=yy+sy), width=.005)
#   }
#  }
# 
# 
# # plot for different indicators
# 
# plotPoints(data=m,xx=m$moran,yy=m$entropy,sx=s$moran,sy=s$entropy,col=m$alpha,with_bars=TRUE)

# DOES NOT FUCKING WORK ???

# plot points
plotPoints<-function(d1,d2,xstring,ystring,colstring){
 p = ggplot(d1, aes_string(x=xstring,y=ystring,col=colstring))
 return(p+ geom_point() + geom_point(data=d2, aes_string(x = xstring, y = ystring),colour=I("red"),shape="+",size=5))
}



plotPoints(m,m[1:10,],"entropy","slope","diffusion")
# ok additional points features works
plotPoints(m,"entropy","distance","diffusion")
plotPoints(m,"entropy","moran","diffusion")
plotPoints(m,"slope","distance","diffusion")
plotPoints(m,"slope","moran","diffusion")
plotPoints(m,"distance","moran","diffusion")

indics = c("moran","distance","entropy","slope")
#par(mfrow=c(2,3))
for(i in 1:3){for(j in (i+1):4){
  show(paste(i,j))
  plotPoints(m,indics[i],indics[j],"rate")
}}



source(paste0(Sys.getenv("CN_HOME"),'/Models/Utils/R/plots.R')


real = read.csv(
  paste0(Sys.getenv("CN_HOME"),'/Results/Synthetic/Density/RealData/Numeric/europe_100km.csv'),
  sep=";"
  )

for(col_par_name in c("diffusion","diffsteps","rate","alpha")){
plots=list()
k=1
#par(mfrow=c(2,3))
for(i in 1:3){for(j in (i+1):4){
  plots[[k]]=plotPoints(m,real,indics[i],indics[j],col_par_name)
  k=k+1
}}

multiplot(plotlist=plots,cols=3)
#savePlot(filename=paste0(Sys.getenv("$CN_HOME"),"/Results/Synthetic/Density/Calibration/",col_par_name,".png"))
}


# interesting...
# Next step : compute for real situations ?

#
plotPoints(m,real,"entropy","slope","diffusion")

# difficult calib ?
# try map some areas to understand real patterns

# real conf
plotSimplifiedBlock(15001,35001)
# against generated
plot(x=raster("temp_raster_pop.asc"),col=colorRampPalette(c("white", "red"))(50))

# !! too much diffusion and too few population
# -> bigger growth rates and smaller diffusions ?

# needs a function calling netlogo from here to visualize a pattern for some params.

library(RNetLogo)
NLStart(nl.path='/Applications/NetLogo/NetLogo 5.1.0/',gui=FALSE)
















