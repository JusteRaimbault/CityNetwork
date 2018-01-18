
library(ggplot2)
library(marima)

source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

resdir = paste0(Sys.getenv('CN_HOME'),'/Results/SpatioTempCausality/Synthetic/arma/')

#'
#' rho[X(t-tau),Y(t)]
getLaggedCorrs <- function(x,y,taumax=10){
  res=data.frame()
  for(tau in -taumax:taumax){
    if(tau>=0){xx=x;yy=y}else{xx=y;yy=x}
    corrs = cor.test(xx[1:(length(xx)-abs(tau))],yy[(abs(tau)+1):(length(yy))])
    estimate = corrs$estimate
    rhomin = corrs$conf.int[1]
    rhomax = corrs$conf.int[2]
    res=rbind(res,data.frame(rho=estimate,rhomin = rhomin,rhomax=rhomax,tau=tau,pval=corrs$p.value,tstat=corrs$statistic))
  }
  return(res)
}
  

plotLaggedCorrs <- function(X,taumax=10){
  df = data.frame()
  for(j1 in 1:(ncol(X)-1)){
    for(j2 in (j1+1):ncol(X)){
      df=rbind(df,data.frame(getLaggedCorrs(X[,j1],X[,j2],taumax = taumax),vars=paste0(j1,"->",j2)))
    }
  }
  g=ggplot(df,aes(x=tau,y=rho,colour=vars,group=vars,ymin=rhomin,ymax=rhomax))
  g+geom_line()+geom_errorbar()+geom_point()+stdtheme
}

laggedCorrs <- function(X,taumax=10,format="rowdf"){
  df = data.frame()
  if(format=="coldf"){df=c()}
  for(j1 in 1:(ncol(X)-1)){
    for(j2 in (j1+1):ncol(X)){
      corrs = getLaggedCorrs(X[,j1],X[,j2],taumax = taumax)
      if(format=="rowdf"){
        df=rbind(df,data.frame(corrs,vars=paste0(j1,"->",j2)))
      }
      if(format=="coldf"){
        df = append(df,corrs$rho)
      }
    }
  }
  if(format=="rowdf"){
    return(df)
  }
  if(format=="coldf"){
    return(data.frame(matrix(df,ncol=length(df))))
  }
}




mtest = marima(marima.sim(kvar=2,nsim=100))

x = marima.sim(kvar=3,nsim=100000)
plotLaggedCorrs(x,taumax = 10)

tf=500000
ar=array(data = c(diag(2),rep(0,4),c(0,0.5,0.5,0)),dim = c(2,2,3))
x=marima.sim(kvar=2,ar.model = ar,nsim=tf)
plot(1:tf,x[,1],type='l');points(1:tf,x[,2],col='red',type='l')
cor.test(x[2:nrow(x),1],x[1:(nrow(x)-1),2])
var(x[,1])
plotLaggedCorrs(x)

laggedcorrs = getLaggedCorrs(x[,1],x[,2],10)

ar=array(data = c(diag(3),c(0,0,0,-1,0,1,0,0,0)),dim = c(3,3,2))
x=marima.sim(kvar=3,ar.model = ar,nsim=10000)
plotLaggedCorrs(x)


ar=array(data = c(diag(4),runif(16,-0.5,0.5)),dim = c(4,4,2))
x=marima.sim(kvar=4,ar.model = ar,nsim=10000,averages = rep(0,2))
plotLaggedCorrs(x,taumax = 10)
eigen(ar[,,2])$values

ar=array(data = c(diag(3),runif(9,-0.5,0.5)),dim = c(3,3,2))
x=marima.sim(kvar=3,ar.model = ar,nsim=10000,averages = rep(0,3))
plotLaggedCorrs(x,taumax = 10)
laggedCorrs(x,format = "coldf")

ar = define.model(kvar=2,ar=c(2),reg.var = c(2))$ar.pattern
plotLaggedCorrs(marima.sim(kvar=2,ar.model = ar,nsim=10000))

tf=10000
epsilon=matrix(rnorm(2*tf),ncol=2)
x=matrix(rep(0,2*tf),ncol=2);x[1,]=epsilon[1,]
for(t in 2:nrow(x)){x[t,]=-0.8*x[t-1,c(2,1)]+epsilon[t,]}
plot(1:nrow(x),x[,1],type='l')


####################
####################

nbootstrap = 10000
maxai = 0.1
lag = 2

# set seed for reproducibility
set.seed(0)

trajs=data.frame();eigs=data.frame()
for(b in 1:nbootstrap){
  if(b%%100==0){show(b)}
  #ar=array(data = c(diag(3),runif(9,-0.5,0.5)),dim = c(3,3,2))
  #x=marima.sim(kvar=3,ar.model = ar,nsim=10000)
  ar=array(data = c(diag(2),rep(0,4),c(0,runif(1,-maxai,maxai),runif(1,-maxai,maxai),0)),dim = c(2,2,3))
  x=marima.sim(kvar=2,ar.model = ar,nsim=10000)
  #plotLaggedCorrs(x)
  trajs=rbind(trajs,laggedCorrs(x,format = "coldf"))
  #eigs=rbind(eigs,eigen(ar[,,2])$values)
  eigs=rbind(eigs,c(-ar[1,2,3],-ar[2,1,3]))
}

# cluster ts
#clust = kmeans(trajs,centers = 8,nstart = 100,iter.max = 100)

#rows = which(Im(eigs[,1])==0&Im(eigs[,2])==0&Im(eigs[,3])==0)

#g=ggplot(data.frame(lambda1=as.numeric(eigs[rows,1]),lambda2=as.numeric(eigs[rows,3]),cluster=clust$cluster[rows]),aes(x=lambda1,y=lambda2,color=cluster))
#g+geom_point()

#g=ggplot(data.frame(a1=eigs[,1],a2=eigs[,2],cluster=clust$cluster),aes(x=a1,y=a2,color=as.character(cluster)))
#g+geom_point()

#ccoef=c()
#for(k in 3:15){clust = kmeans(trajs,centers = k,nstart = 100,iter.max = 100);ccoef=append(ccoef,clust$betweenss/clust$totss)}
#plot(3:15,ccoef,type='l')
# -> k=9 propre

nclust = 9
clust = kmeans(trajs,centers = nclust,nstart = 1000,iter.max = 100)

g=ggplot(data.frame(a1=eigs[,1],a2=eigs[,2],cluster=as.character(clust$cluster)),aes(x=a1,y=a2,color=cluster))
g+geom_point(size=0.5)+xlab(expression(a[1]))+ylab(expression(a[2]))+stdtheme
ggsave(paste0(resdir,'coefsclust_nbootstrap',nbootstrap,'_maxai',gsub(pattern = '.',replacement = '_',x=maxai,fixed = T),'_lag',lag,'nclust',nclust,'.png'),width=22,height=20,units='cm')

timetrajs=data.frame()
for(cluster in 1:nrow(clust$centers)){
  timetrajs=rbind(timetrajs,cbind(rho=clust$centers[cluster,],cluster=rep(cluster,ncol(clust$centers)),tau=-10:10))
}
g=ggplot(timetrajs,aes(x=tau,y=rho,color=as.character(cluster),group=cluster))
g+geom_point()+geom_line()+facet_wrap(~cluster)+scale_color_discrete(name="cluster")+xlab(expression(tau))+ylab(expression(rho[tau]))+stdtheme
ggsave(paste0(resdir,'centertrajs_nbootstrap',nbootstrap,'_maxai',gsub(pattern = '.',replacement = '_',x=maxai,fixed = T),'_lag',lag,'nclust',nclust,'.png'),width=22,height=20,units='cm')


