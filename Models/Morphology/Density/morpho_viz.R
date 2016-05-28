
##############
## Analysis and Visualization of morphological density analysis
##############

library(RColorBrewer)
library(ggplot2)
library(MASS)
library(dplyr)

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
#real_ind = real[5*(0:(nrow(real)/5))+1,]


###################
# Check spatial distribution of indicators
###################


indic="distance"
p = ggplot(data.frame(x=real$y,y=1-real$x,density_max=real[[indic]]),aes(x=x,y=y,colour=density_max))
p+geom_point()+xlab("")+ylab("")+labs(title=indic)+scale_colour_gradientn(colours=rev(rainbow(5)))+scale_y_continuous(breaks=NULL)+scale_x_continuous(breaks=NULL)

# * use spatial smoothing ? (bord effect of mask square shape, 
#     give square patterns for "thresholded" indicators, as max or moran)
# * kill outsiders ? issue meanDistance in Narvik and northern Sweden

map<-function(indic){
  d=data.frame(x=real$y,y=1-real$x);d[[indic]]=real[[indic]]
  p=ggplot(d,aes_string(x="x",y="y",colour=indic))
  p+geom_point(shape=".",size=1)+xlab("")+ylab("")+labs(title=indic)+scale_colour_gradientn(colours=rev(rainbow(5)))+scale_y_continuous(breaks=NULL)+scale_x_continuous(breaks=NULL)
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
laws=c("log-normal","inv-log-normal","inv-log-normal","normal")
#laws=rep("",4)
ranges=list((1:250)/1000,(1:1000)/1000,(1:1000)/1000,(-2500:-500)/1000)
k=1
for(indic in indics){
  #hist(real[[indic]],breaks=500,main="",xlab=indic,freq=FALSE)
  hist(max(real[indic]) - real[[indic]]+1e-4,breaks=500,main="",xlab=indic,freq=FALSE)
  
  
  if(laws[k]=="log-normal"){
   fit = coef(fitdistr(abs(real[[indic]]),laws[k]))
   dens=dlnorm(ranges[[k]],meanlog=fit[1],sdlog=fit[2])#*sign(fit[1])
 }
 if(laws[k]=="inv-log-normal"){
   # fit on inversed distrib in that case
   fit = coef(fitdistr(max(real[indic]) - real[[indic]]+1e-4,"log-normal"))
   dens=dlnorm(ranges[[k]],meanlog=fit[1],sdlog=fit[2])
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
#k=10;
vars = c(3,4,5,6)
ccoef=c()
par(mfrow=c(3,3))
for(k in 3:11){
  show(k)
  clust = kmeans(real[,vars],k,iter.max=30)
  #ccoef=append(ccoef,sum(clust$withinss/clust$size)/k)# mean cluster size
  withinProp=clust$tot.withinss/(clust$betweenss+clust$tot.withinss)
  ccoef=append(ccoef,withinProp)# clust coef
  plot(real$y,1-real$x,col=clust$cluster,pch='.',cex=3,main=paste0('k=',k,' ; withinProp=',withinProp),xlab="",ylab="",xaxt='n',yaxt='n')
}

# TODO : add "typical" profile next to each cluster 


# on rotated data (principal components)



#############
# Local Correlations
#############

x = sort(unique(real$x));y = sort(unique(real$y))
xstep=x[2]-x[1];ystep=y[2]-y[1]
xx = x[seq(from=4,to=length(x)-3,by=4)]
yy = y[seq(from=4,to=length(y)-3,by=4)]

cors = list()#matrix(0,length(xx)*length(yy),6)
i=1
for(x0 in xx){
  for(y0 in yy){
    if(i%%1000==0){show(i)}
     rows = (abs(real$x-x0)<=(3*xstep))&(abs(real$y-y0)<=(3*ystep))
     if(length(which(rows))>10){
       rho=cor(real[rows,3:6])
       cors[[i]]=c(x0,y0,rho[2,1],rho[3,1],rho[4,1],rho[3,2],rho[4,2],rho[4,3])
     }
     i=i+1
  }
}

mcors = matrix(data = unlist(cors),ncol = 8,byrow = TRUE)

map<-function(data,col){
  d=data.frame(x=data[,2],y=1-data[,1],indic=data[,col]);
  p=ggplot(d,aes_string(x="x",y="y",colour="indic"))
  p+geom_point(shape=15,size=2)+xlab("")+ylab("")+labs(title=indic)+scale_colour_gradientn(colours=rev(rainbow(5)))+scale_y_continuous(breaks=NULL)+scale_x_continuous(breaks=NULL)
}

map(mcors,6)




