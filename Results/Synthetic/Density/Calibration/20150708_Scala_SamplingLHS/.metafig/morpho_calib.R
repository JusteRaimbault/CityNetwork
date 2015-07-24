
####################
## Analysis of Morpho Analysis Calibration
####################

# setwd with env var : need Sys.getenv
setwd(paste0(Sys.getenv("CN_HOME"),'/Models/Synthetic/Density'))

# load plot utils
source(paste0(Sys.getenv("CN_HOME"),'/Models/Utils/R/plots.R'))



#############################
#############################




# load result
res = read.csv('res_oml_scala/2015_07_08_19_26_19_LHSsampling.csv',sep=',')
# transform as usable data structure
indics_cols = c(4,5,7,10,11)
params_cols = c(1,2,3,6,8)
p = getSingleParamPoints(res,params_cols,indics_cols)

# ggplot

library(ggplot2)

# simple plot

# data frame of means
indics_cols_m = 1:5
m=data.frame(matrix(data=unlist(p$mean),ncol=5,byrow=TRUE),matrix(data=unlist(p$param),ncol=5,byrow=TRUE));names(m)<- c("distance","entropy","moran","rsquared","slope","alphalocalization","diffusion","diffusionsteps","growthrate","population")
s=data.frame(matrix(data=unlist(p$sd),ncol=5,byrow=TRUE));names(s)<- c("distance","entropy","moran","rsquared","slope")


# indicators
indics = c("distance","entropy","moran","slope")



#plotPoints(m,m[1:10,],"entropy","slope","diffusion")
# ok additional points features works
plotPoints(d1=m,d2=real,xstring="slope",ystring="moran",colstring="population")
plotPoints(m,xstring="entropy",ystring="moran",colstring="diffusion")
plotPoints(m,"slope","distance","diffusion")
plotPoints(m,"slope","moran","diffusion")
plotPoints(m,"distance","moran","diffusion")


#par(mfrow=c(2,3))
for(i in 1:3){for(j in (i+1):4){
  show(paste(i,j))
  plotPoints(m,real,indics[i],indics[j],"rate")
}}


real_raw = read.csv(
  paste0(Sys.getenv("CN_HOME"),'/Results/Morphology/Density/Numeric/europe_50km_sam.-juin-27-03:00:19-2015.csv'),
  sep=";"
)

# no na
real =real_raw[!is.na(real_raw[,3])&!is.na(real_raw[,4])&!is.na(real_raw[,5])&!is.na(real_raw[,6])&!is.na(real_raw[,7])&!is.na(real_raw[,8])&!is.na(real_raw[,9]),]
# nor outsiders
real=real[real[,3]<quantile(real[,3],0.9)&real[,3]>quantile(real[,3],0.1)&real[,4]<quantile(real[,4],0.9)&real[,4]>quantile(real[,4],0.1)&real[,5]<quantile(real[,5],0.9)&real[,5]>quantile(real[,5],0.1)&real[,6]<quantile(real[,6],0.9)&real[,6]>quantile(real[,6],0.1),]

# only "big cities"
real=real[real$pop>500000,]

# renormalize
for(j in 1:ncol(real)){real[,j]=(real[,j]-min(real[,j]))/(max(real[,j])-min(real[,j]))}

# indepednant measurement
# : disjoint areas - offset/gridSize
real = real[5*(0:(nrow(real)/5))+1,]

#sample :: no need
real = real[sample.int(length(real[,1]),500),]

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

for(col_par_name in c("diffusion","diffusionsteps","growthrate","alphalocalization")){
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



####################
## Calib using prcomp analysis
####################

# prcomp on real
real =real_raw[!is.na(real_raw[,3])&!is.na(real_raw[,4])&!is.na(real_raw[,5])&!is.na(real_raw[,6])&!is.na(real_raw[,7])&!is.na(real_raw[,8])&!is.na(real_raw[,9]),]
real=real[real[,3]<quantile(real[,3],0.9)&real[,3]>quantile(real[,3],0.1)&real[,4]<quantile(real[,4],0.9)&real[,4]>quantile(real[,4],0.1)&real[,5]<quantile(real[,5],0.9)&real[,5]>quantile(real[,5],0.1)&real[,6]<quantile(real[,6],0.9)&real[,6]>quantile(real[,6],0.1),]
real=real[real$pop>500000,]
for(j in 1:ncol(real)){real[,j]=(real[,j]-min(real[,j]))/(max(real[,j])-min(real[,j]))}

summary(prcomp(real[,3:9]))
prcomp(real[,3:6])

# prcomp on results

synth = m[,c(1,2,3,4,5,10)]

for(j in 1:ncol(synth)){synth[,j]=(synth[,j]-min(synth[,j]))/(max(synth[,j])-min(synth[,j]))}

summary(prcomp(synth))
summary(prcomp(synth[,c(1,2,3,5)]))
prcomp(synth[,c(1,2,3,5)])


# seems intuitively better to do the pca on subset with more variability
#  ~ synth in our case as union of both is not really bigger
#  (for big cities)









########################

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









