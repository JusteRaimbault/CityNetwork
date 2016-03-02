
# test R indicators
setwd(paste0(Sys.getenv("CN_HOME"),'/Models/Synthetic/Density'))
source('morpho.R')

z=read.csv('omlplugin/tmp/pop_02.csv',sep=";",header=FALSE)
r_pop = raster(matrix(data=unlist(z),nrow=nrow(z),byrow=TRUE))
r_dens = r_pop/cellStats(r_pop,sum)

show(paste0('moran : ',moranIndex()))
show(paste0('moran focal : ',convolMoran()))
show(paste0('averageDistance : ',averageDistance()))
show(paste0('entropy : ',entropy()))
show(paste0('rankSizeSlope : ',rankSizeSlope()))

