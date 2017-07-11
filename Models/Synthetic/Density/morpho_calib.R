
####################
## Analysis of Morpho Analysis Calibration
####################

# setwd with env var : need Sys.getenv
setwd(paste0(Sys.getenv("CN_HOME"),'/Models/Synthetic/Density'))
# load plot utils
source(paste0(Sys.getenv("CN_HOME"),'/Models/Utils/R/plots.R'))
# ggplot
library(ggplot2)
library(dplyr)


#############################
#############################
# Prepare the Data
############################


# load result
#res = read.csv('res_oml_scala/2015_08_06_17_02_12_LHSsampling.csv',sep=',')
res = as.tbl(read.csv(paste0(Sys.getenv("CN_HOME"),'/Results/Synthetic/Density/20151110_GridLHS/2015_11_10_18_11_05_GRID_LHS.csv'),sep=','))
# transform as usable data structure
#indics_cols = c(4,5,7,10,11)
indics_cols = 6:10
#params_cols = c(1,2,3,6,8)
params_cols = 1:5
p = getSingleParamPoints(res,params_cols,indics_cols)

# simple plot

# data frame of means
indics_cols_m = 1:5
params_cols_m = 6:10
m=data.frame(matrix(data=unlist(p$mean),ncol=5,byrow=TRUE),matrix(data=unlist(p$param),ncol=5,byrow=TRUE));names(m)<- c("distance","entropy","moran","rsquared","slope","alphalocalization","diffusion","diffusionsteps","growthrate","population")
med=data.frame(matrix(data=unlist(p$med),ncol=5,byrow=TRUE),matrix(data=unlist(p$param),ncol=5,byrow=TRUE));#names(med)<- c("distance","entropy","moran","rsquared","slope","alphalocalization","diffusion","diffusionsteps","growthrate","population")
s=data.frame(matrix(data=unlist(p$sd),ncol=5,byrow=TRUE));names(s)<- c("distance","entropy","moran","rsquared","slope")
params=m[,params_cols_m]

# indicators
indics = c("distance","entropy","moran","rsquared","slope")

##########################


#################
## First tests
#################

#plotPoints(m,m[1:10,],"entropy","slope","diffusion")
# ok additional points features works
#plotPoints(d1=m,d2=real,xstring="slope",ystring="moran",colstring="population")
#plotPoints(m,xstring="entropy",ystring="moran",colstring="diffusion")
#plotPoints(m,"slope","distance","diffusion")
#plotPoints(m,"slope","moran","diffusion")
#plotPoints(m,"distance","moran","diffusion")


#par(mfrow=c(2,3))
for(i in 1:3){for(j in (i+1):4){
  show(paste(i,j))
  plotPoints(m,real,indics[i],indics[j],"rate")
}}

####################


#####################
## Simple stats on raw
#####################

# histograms
rows = spec_regime_rows
#rows = 1:nrow(res)
par(mfrow=c(2,2))
for(indic_num in c(1:3,5)){
  hist(res[rows,indics_cols[indic_num]],breaks=1000,main=indics[indic_num],xlab="")
}

# separate modes ?
par(mfrow=c(1,1))
#distance
dist = res[,indics_cols[1]]
hist(dist[dist>0.85&dist<1],breaks=300,main="distance",xlab="")
#entropy
entr = res[,indics_cols[2]]
hist(entr[entr<0.9],breaks=300,main="entropy",xlab="")

# histograms with fit ? 
#TODO


# histograms for points where distance has a gaussian distrib
#spec_regime_rows = which(dist>0.85)
spec_regime_rows = which(dist<0.85)
# -> relaunch hists




####################


##################
## Real Data
##################

# load real_raw
real_raw = read.csv(
  paste0(Sys.getenv("CN_HOME"),'/Results/Morphology/Density/Numeric/20150806_europe50km_10kmoffset_100x100grid.csv'),
  sep=";"
)

# no na
real =real_raw[!is.na(real_raw[,3])&!is.na(real_raw[,4])&!is.na(real_raw[,5])&!is.na(real_raw[,6])&!is.na(real_raw[,7])&!is.na(real_raw[,8])&!is.na(real_raw[,9]),]
# nor outsiders
#real=real[real[,3]<quantile(real[,3],0.9)&real[,3]>quantile(real[,3],0.1)&real[,4]<quantile(real[,4],0.9)&real[,4]>quantile(real[,4],0.1)&real[,5]<quantile(real[,5],0.9)&real[,5]>quantile(real[,5],0.1)&real[,6]<quantile(real[,6],0.9)&real[,6]>quantile(real[,6],0.1),]

# only "big cities"
#real=real[real$pop>500000,]

# renormalize
for(j in 1:ncol(real)){real[,j]=(real[,j]-min(real[,j]))/(max(real[,j])-min(real[,j]))}

# indepednant measurement
# : disjoint areas - offset/gridSize
real = real[5*(0:(nrow(real)/5))+1,]

#sample :: needed for quick plotting
real = real[sample.int(length(real[,1]),1000),]

# check graph
plotPoints(m,real,"entropy","slope","diffusion")
##################


################
# Check independance of objectives
#################

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
########################


####################
## Calib using prcomp analysis
####################

##################
# prcomp on real
##################
real =real_raw[!is.na(real_raw[,3])&!is.na(real_raw[,4])&!is.na(real_raw[,5])&!is.na(real_raw[,6])&!is.na(real_raw[,7])&!is.na(real_raw[,8])&!is.na(real_raw[,9]),]
real=real[real[,3]<quantile(real[,3],0.9)&real[,3]>quantile(real[,3],0.1)&real[,4]<quantile(real[,4],0.9)&real[,4]>quantile(real[,4],0.1)&real[,5]<quantile(real[,5],0.9)&real[,5]>quantile(real[,5],0.1)&real[,6]<quantile(real[,6],0.9)&real[,6]>quantile(real[,6],0.1),]
real=real[real$pop>500000,]
for(j in 1:ncol(real)){real[,j]=(real[,j]-min(real[,j]))/(max(real[,j])-min(real[,j]))}

summary(prcomp(real[,3:9]))
prcomp(real[,3:6])
##################



#################
# prcomp on results
#################

synth = m[,c(1,2,3,4,5,10)]

for(j in 1:ncol(synth)){synth[,j]=(synth[,j]-min(synth[,j]))/(max(synth[,j])-min(synth[,j]))}

summary(prcomp(synth))
summary(prcomp(synth[,c(1,2,3,5)]))
prcomp(synth[,c(1,2,3,5)])


# seems intuitively better to do the pca on subset with more variability
#  ~ synth in our case as union of both is not really bigger
#  (for big cities)

##############
# Visualization in (PC1,PC2) for model results only
##############

pr <- prcomp(synth[,c(1,2,3,5)]);rot=pr$rotation
pcsynth = as.matrix(synth[,c(1,2,3,5)])%*%pr$rotation

# test plot
plot(pcsynth[,1],pcsynth[,2])
plotPoints(d1=data.frame(pcsynth[,1:2],m[,params_cols_m]),d2=NULL,"PC1","PC2","growthrate")
# and same with other params...

# visualize grids corresponding to extreme values.
# -> getRepresentative() function needed





#############
## Calibration
#############

#############
#############
# OR test : prcomp on set { (R_i - S_j)_k | R_i \in sample(Real), S_j \in Synth, k \in indics }
# -- without right outsiders - distance ONLY --

real =real_raw[!is.na(real_raw[,3])&!is.na(real_raw[,4])&!is.na(real_raw[,5])&!is.na(real_raw[,6])&!is.na(real_raw[,7])&!is.na(real_raw[,8])&!is.na(real_raw[,9]),]
#real=real[real[,3]<quantile(real[,3],0.9),3:6]
real=real[,3:6]
real=as.matrix(real[sample.int(length(real[,1]),500),])
synth = as.matrix(m[sample.int(length(m[,1]),4000),c(3,1,2,5)])

# construct product using kronecker
diffs = (real %x% rep(1,nrow(synth))) - (rep(1,nrow(real)) %x% synth)

pca = prcomp(normalize(diffs))
summary(pca)

# -> 90% of explained variance
rot = pca$rotation
plotPoints(data.frame(synth%*%rot,m[,params_cols_m]),data.frame(real%*%rot),"PC1","PC2","diffusion")

# aggregate on PCs ?
# and take min_real(||(real-synth)_PC||^2)

sr = (synth%*%rot) ; rr =  (real%*%rot)

# WRONG DISTANCE
#d1 = sapply(sr[,1],function(x){min((rr[,1]-x)^2)})
#d2 = sapply(sr[,2],function(x){min((rr[,2]-x)^2)})
#d=d1+d2

# GOOD DISTANCE : min_sr d(rr_i,sr)
d=apply(sr[,1:2],1,function(z){min((rr[,1]-z[1])^2 + (rr[,2]-z[2])^2)})

threshold = 1e-4

#hist(d,breaks=200)
#hist(d[d<threshold],breaks=200)

par(mfrow=c(2,2))
for(threshold in c(1e-6,1e-5,1e-4,1e-3)){

# get the corresponding parameters
params=m[,params_cols_m]
best_params_rows = which(d<threshold)
best_params = m[best_params_rows,]#params[best_params_rows,];nrow(best_params)

# check distance
plot(sr[best_params_rows,1:2],col="blue",main=paste0("threshold=",threshold," ; ",nrow(best_params)," points"),pch="+",cex=1)
points(rr[,1:2],col="red",pch="+",cex=1)
points(sr[best_params_rows,1:2],col="blue",pch="+",cex=1)

}

# corresponding hypercube
apply(best_params,2,min)
apply(best_params,2,max)
apply(best_params,2,mean)


# -> extract configs from pop directory in other script, given the best_params matrix
# threshold = 1e-4


## try to draw some kind of calibration profiles
# given a parameter, cut it, find points with value within, take the min.

plotCalibProfile<-function(param_col,breaks,name){
  cuts = cut(params[,param_col],breaks,labels=FALSE)
  profile=c()
  for(b in 1:breaks){
     if(length(which(cuts==b))==0){m=NA}else{   m =min(d[cuts==b])}
     profile=append(profile,m)
  }
  plot(sort(unique(cuts)),profile,main=name)
}

plotCalibProfile(2,40,"diffusion")
plotCalibProfile(4,20,"growthrate")


## try to check simple linear models linking parameters and indicators








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









