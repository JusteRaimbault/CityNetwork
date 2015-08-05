
# test R indicators
setwd(paste0(Sys.getenv("CN_HOME"),'/Models/Synthetic/Density'))
source('morpho.R')

r_pop = raster(matrix(data=unlist(read.csv('omlplugin/tmp/pop_02.csv',sep=";",header=FALSE)),nrow=50,byrow=TRUE))
r_dens = r_pop/cellStats(r_pop,sum)

moranIndex()
averageDistance()
entropy()
rankSizeSlope()

