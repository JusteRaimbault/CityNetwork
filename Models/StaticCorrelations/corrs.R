
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
raw=read.csv(file="res/testcentre_areasize100_offset50_factor0.5_Mar-aoû-23-16:21:44-2016.csv",sep=";",header=TRUE)
rows=apply(raw,1,function(r){prod(as.numeric(!is.na(r)))>0})
res=raw[rows,]

# convert to raster ? not necessary if no use of focal (but better to plot !)

# coords where to compute correlations
#  -- steps must be here in number of measure square, not in pixels --

istep=1;jstep=1;rhoasize=5
xcors=sort(unique(res[,1]));xcors=xcors[seq(from=rhoasize/2,to=length(xcors)-(rhoasize/2),by=istep)]
ycors=sort(unique(res[,2]));ycors=ycors[seq(from=rhoasize/2,to=length(ycors)-(rhoasize/2),by=jstep)]
xstep=diff(xcors)[1];ystep=diff(ycors)[2]
xyrhoasize = xstep/istep*rhoasize

corrs = getCorrMatrices(xcors,ycors,xyrhoasize,res)
#corrs = getCorrMatrices(xcors,ycors,xyrhoasize,res,function(m){crossCorrelations(m,3:9,10:22)})
# rq : far more slower with handmade cross-corr : better use built-in cor function and aggregate by projecting only on cross-cors


# test plotting mean abs corr
rcross = dfToRaster(getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho[1:7,8:20]))}))
rmorph = dfToRaster(getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho[1:7,1:7]))}))
rnet = dfToRaster(getCorrMeasure(xcors,ycors,corrs,function(rho){diag(rho)<-0;return(mean(rho[8:20,8:20]))}))
rpop=dfToRaster(raw,col=8);rpop=crop(rpop,extent(rmorph))

par(mfrow=c(2,2))
plot(rpop,main="pop");plot(rmorph,main="morpho");plot(rnet,main="network");plot(rcross,main="cross")

#
par(mfrow=c(4,5))
for(j in 3:22){plot(dfToRaster(raw,col=j),main=colnames(raw)[j])}


# multi raster plot ?







