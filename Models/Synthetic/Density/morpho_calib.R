
####################
## Analysis of Morpho Analysis Calibration
####################

# setwd with env var : need Sys.getenv
setwd(paste0(Sys.getenv("CN_HOME"),'/Models/Synthetic/Density'))



#############################
#############################

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






#############################
#############################




# load result
res = read.csv('res_oml/2015_06_12_17_41_44_sampling.csv',sep=',')


# test
p = getSingleParamPoints(res,c(1,2,3,6),c(4,5,7,8),100)

# ggplot

library(ggplot2)

# simple plot

# data frame of means
m = data.frame(moran=p[[2]][,1],distance=p[[2]][,2],
               entropy=p[[2]][,3],slope=p[[2]][,4],
               diffusion=p[[1]][,1],diffsteps=p[[1]][,2],alpha=p[[1]][,3],rate=p[[1]][,4])

# data frame of stds
s = data.frame(moran=p[[3]][,1],distance=p[[3]][,2],entropy=p[[3]][,3],slope=p[[3]][,4])

# indicators
indics = c("moran","distance","entropy","slope")



#plotPoints(m,m[1:10,],"entropy","slope","diffusion")
# ok additional points features works
#plotPoints(m,"entropy","distance","diffusion")
#plotPoints(m,"entropy","moran","diffusion")
#plotPoints(m,"slope","distance","diffusion")
#plotPoints(m,"slope","moran","diffusion")
#plotPoints(m,"distance","moran","diffusion")


#par(mfrow=c(2,3))
for(i in 1:3){for(j in (i+1):4){
  show(paste(i,j))
  plotPoints(m,real,indics[i],indics[j],"rate")
}}


# load plot utils
source(paste0(Sys.getenv("CN_HOME"),'/Models/Utils/R/plots.R'))


real_raw = read.csv(
  #paste0(Sys.getenv("CN_HOME"),'/Results/Synthetic/Density/RealData/Numeric/france_20km_mar.-juin-09-23:46:42-2015.csv'),
  paste0(Sys.getenv("CN_HOME"),'/Results/Synthetic/Density/RealData/Numeric/europe_50km_sam.-juin-27-03:00:19-2015.csv'),
  sep=";"
)

# no na
real =real_raw[!is.na(real_raw[,3])&!is.na(real_raw[,4])&!is.na(real_raw[,5])&!is.na(real_raw[,6])&!is.na(real_raw[,7])&!is.na(real_raw[,8])&!is.na(real_raw[,9]),]

# renormalize
for(j in 1:ncol(real)){real[,j]=(real[,j]-min(real[,j]))/(max(real[,j])-min(real[,j]))}

# indepednant measurement
# : disjoint areas - offset/gridSize
real = real[5*(0:(nrow(real)/5))+1,]

#sample :: no need
#real = real[sample.int(length(real[,1]),500),]

plotPoints(m,real,"moran","entropy","diffusion")

####--------------
# Check independance of objectives
##

cor(real[,3:9])
pr=prcomp(real[,3:9])
r=pr$rotation
cor(real*r)

summary(prcomp(real))
summary(prcomp(real[,1:3]))
summary(prcomp(real[,2:4]))
summary(prcomp(real[,c(1,2,4)]))

summary(prcomp(m[,1:4]))

# because superposed areas (with ≠ origin phases) -> strongly dependant
# should do the pca on 1/4 --> OK
# dim ~ 3.5, quite good


########################
# multiplots
########################

for(col_par_name in c("diffusion","diffsteps","rate","alpha")){
  plots=list()
  k=1
  #par(mfrow=c(2,3))
  for(i in 1:3){
    for(j in (i+1):4){
      plots[[k]]=plotPoints(m,real,indics[i],indics[j],col_par_name)
      k=k+1
    }
  }

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

#library(RNetLogo)
#NLStart(nl.path='/Applications/NetLogo/NetLogo 5.1.0/',gui=FALSE)

# or rewrite the generator in R ?




#############
## Compare real data computations
#############

real20 = read.csv(
  paste0(Sys.getenv("CN_HOME"),'/Results/Synthetic/Density/RealData/Numeric/france_20km_mar.-juin-09-23:46:42-2015.csv'),
  sep=";"
)
real20 =real20[!is.na(real20[,3]),3:6]
real20$green = rep("green",nrow(real20))

real100 = read.csv(paste0(Sys.getenv("CN_HOME"),'/Results/Synthetic/Density/RealData/Numeric/europe_100km.csv'),sep=";")

plotPoints(real20,real100,"entropy","slope","green")









