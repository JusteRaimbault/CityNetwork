
## Analysis and Visualization of moephological density analysis

library(RColorBrewer)

real_raw = read.csv(
  #paste0(Sys.getenv("CN_HOME"),'/Results/Synthetic/Density/RealData/Numeric/france_20km_mar.-juin-09-23:46:42-2015.csv'),
  paste0(Sys.getenv("CN_HOME"),'/Results/Morphology/Density/Numeric/europe_50km_sam.-juin-27-03:00:19-2015.csv'),
  sep=";"
)


# no na
real_raw =real_raw[!is.na(real_raw[,3])&!is.na(real_raw[,4])&!is.na(real_raw[,5])&!is.na(real_raw[,6])&!is.na(real_raw[,7])&!is.na(real_raw[,8])&!is.na(real_raw[,9]),]

# # kill last quintile (only for distance)
rows=rep(TRUE,nrow(real_raw))
no_outsiders_cols=c(4)
for(j in no_outsiders_cols){
  rows=rows&(real_raw[,j]<quantile(real_raw[,j],0.95,na.rm=TRUE))
}
real=real_raw[rows,]

# renormalize
for(j in 1:ncol(real_raw)){
  real[,j]=(real[,j]-min(real[,j]))/(max(real[,j])-min(real[,j]))
}

# indep measurements
real_ind = real[5*(0:(nrow(real)/5))+1,]


###################
# Check spatial distribution of indicators
###################

indic="moran"
plot(
  real$y,1-real$x,
  col= colorRampPalette(c( "darkgrey","yellow","red"))(10000)[cut(real[[indic]],10000,labels=FALSE)],
  pch=16,cex=0.5,xaxt="n",yaxt="n",xlab="",ylab="",
  main=indic,legend=TRUE
)

# * use spatial smoothing ? (bord effect of mask square shape, 
#     give square patterns for "thresholded" indicators, as max or moran)
# * kill outsiders ? issue meanDistance in Narvik and northern Sweden


###########
# Descriptive Statistics
###########

plot(real[sample.int(nrow(real),size=1000),3:6],pch="+")
plot(real[,3:6],pch="+")





