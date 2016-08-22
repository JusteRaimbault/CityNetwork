
####
#  Correlations
#

#  - extraction of spatial "stationarity scales" -> make the step vary
#  - algo for variable areas ?
#  - find "optimal" correlation scale ? (rho = f(scale), 
#       should vanish when increase - what behavior in small ? use correlation t-test (bof if vars not normal) ?
#       -> size of conf.int renormalized by n ?
#  - Q : link between stationarity and ergodicity ?
#  
#  Q : what measures of corr ? (indic by indic corrs ? Principal Components ? Spectral radius ? mean abs ? etc.)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))
source('functions.R')


# load data
res=read.csv('res/')

# convert to raster ? not necessary if no use of focal (but better to plot !)

# coords where to compute correlations
#  -- steps must be here in number of measure square, not in pixels --
xstep=100;ystep=100
xcors=unique(res[,1]);xcors=xcors[seq(from=xstep/2,to=length(xcors)-(xstep/2),by=xstep)]
ycors=unique(res[,2]);ycors=ycors[seq(from=ystep/2,to=length(ycors)-(ystep/2),by=ystep)]

corrs=list()
for(x in xcors){
  for(y in ycors){
    # compute correlation matrix ?
    rows = abs(res[,1]-x)<xstep/2&abs(res[,2]-y)<ystep/2
    rho = cor(res[rows,c(-1,-2)])
    corrs[[x]][[y]]=rho
  }
}


# test plotting mean abs corr
r = dfToRaster(getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(abs(rho)))}))

# multi raster plot







