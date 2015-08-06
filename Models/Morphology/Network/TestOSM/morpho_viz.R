
##############
## Analysis and Visualization of morphological density analysis
##############

library(RColorBrewer)
library(ggplot2)
library(MASS)
source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

# data

real_raw = read.csv(
  paste0(Sys.getenv("CN_HOME"),'/Results/Morphology/Density/Numeric/20150806_europe50km_10kmoffset_100x100grid.csv'),
  sep=";"
)


# no na
real =real_raw[!is.na(real_raw[,3])&!is.na(real_raw[,4])&!is.na(real_raw[,5])&!is.na(real_raw[,6])&!is.na(real_raw[,7])&!is.na(real_raw[,8])&!is.na(real_raw[,9]),]

# renormalize -> if PCA needed
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

map<-function(indic){
  d=data.frame(x=real$y,y=1-real$x);d[[indic]]=real[[indic]]
  p=ggplot(d,aes_string(x="x",y="y",colour=indic))
  p+geom_point(shape=".",size=2)+xlab("")+ylab("")+labs(title=indic)+scale_colour_gradientn(colours=rev(rainbow(5)))+scale_y_continuous(breaks=NULL)+scale_x_continuous(breaks=NULL)
}

# multiplots
indics=c("moran","distance","entropy","slope")
plots=list();k=1
for(indic in indics){
 plots[[k]]=map(indic)
 k=k+1
}
multiplot(plotlist=plots,cols=2)


###########
# Descriptive Statistics
###########

real=real[real$pop>500000,]

plot(real[sample.int(nrow(real),size=2000),3:6],pch="+")
plot(real[,3:6],pch="+")

# hists
par(mfrow=c(2,2))
indics=c("moran","distance","entropy","slope");
laws=c("log-normal","log-normal","normal","normal")
ranges=list((1:250)/1000,(1:100)/1000,(600:1000)/1000,(-2500:-500)/1000)
k=1
for(indic in indics){
 hist(real[[indic]],breaks=500,main="",xlab=indic,freq=FALSE)
 if(laws[k]=="log-normal"){
   fit = coef(fitdistr(abs(real[[indic]]),laws[k]))
   dens=dlnorm(ranges[[k]],meanlog=fit[1],sdlog=fit[2])#*sign(fit[1])
 }
 if(laws[k]=="inv-log-normal"){
   # fit on inversed distrib in that case
   fit = coef(fitdistr(rev(real[[indic]]),"log-normal"))
   dens=rev(dnorm(ranges[[k]],mean=fit[1],sd=fit[2]))
 }
 if(laws[k]=="normal"){
   fit = coef(fitdistr(real[[indic]],"normal"))
   dens=dnorm(ranges[[k]],mean=fit[1],sd=fit[2])
 }
 points(ranges[[k]],dens,type="l",col="red")
 k=k+1
}


###############
# Clustering
###############

# with all data (incl pop and max) :: cols = 3:9
# test various cluster vals
#  - all : cols = 3:9
#  - with (pop,max,rsquared)
#  - without distance
k=10;
vars = c(3,5,6)
ccoef=c()
for(k in 1:15){
  show(k)
  clust = kmeans(real[,vars],k,iter.max=30)
  #ccoef=append(ccoef,sum(clust$withinss/clust$size)/k)# mean cluster size
  ccoef=append(ccoef,clust$tot.withinss/clust$betweenss)# clust coef
  plot(real$y,1-real$x,col=clust$cluster,pch='.',cex=3,main=paste0('k=',k),xlab="",ylab="",xaxt='n',yaxt='n')
}

# TODO : add "typical" profile next to each cluster 


# on rotated data (principal components)







