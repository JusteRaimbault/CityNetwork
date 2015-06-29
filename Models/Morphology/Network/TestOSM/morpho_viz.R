
## Analysis and Visualization of moephological density analysis

library(RColorBrewer)
library(ggplot2)
library(MASS)

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
#for(j in 1:ncol(real_raw)){
#  real[,j]=(real[,j]-min(real[,j]))/(max(real[,j])-min(real[,j]))
#}

# indep measurements
real_ind = real[5*(0:(nrow(real)/5))+1,]


###################
# Check spatial distribution of indicators
###################


indic="max"
p = ggplot(data.frame(x=real$y,y=1-real$x,density_max=real[[indic]]),aes(x=x,y=y,colour=density_max))
p+geom_point()+xlab("")+ylab("")+labs(title=indic)+scale_colour_gradientn(colours=rev(rainbow(5)))+scale_y_continuous(breaks=NULL)+scale_x_continuous(breaks=NULL)

# * use spatial smoothing ? (bord effect of mask square shape, 
#     give square patterns for "thresholded" indicators, as max or moran)
# * kill outsiders ? issue meanDistance in Narvik and northern Sweden


###########
# Descriptive Statistics
###########

plot(real[sample.int(nrow(real),size=2000),3:6],pch="+")
plot(real[,3:6],pch="+")

# hists
indic="distance"
hist(real[[indic]],breaks=1000,main="",xlab=indic,freq=FALSE)
fit = coef(fitdistr(real[[indic]],"log-normal"))
points((1:2000)/1000,dlnorm((1:2000)/1000,meanlog=fit[1],sdlog=fit[2]),type="l",col="red")



###############
# Clustering
###############

# with all data (incl pop and max)
# test various cluster vals
k=10;ccoef=c()
for(k in 1:15){
  show(k)
  clust = kmeans(real[,3:9],k,iter.max=30)
  #ccoef=append(ccoef,sum(clust$withinss/clust$size)/k)# mean cluster size
  ccoef=append(ccoef,clust$tot.withinss/clust$betweenss)# clust coef
  #plot(real$y,1-real$x,col=clust$cluster,pch='.',cex=3,main=paste0('k=',k),xlab="",ylab="",xaxt='n',yaxt='n')
}




