
library(marima)

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
  g+geom_line()+geom_errorbar()
}




mtest = marima(marima.sim(kvar=2,nsim=100))

ar=array(data = c(diag(2),c(0,0,-1,0)),dim = c(2,2,2))
x=marima.sim(kvar=2,ar.model = ar,nsim=100000)
#plot(1:1000,x[,1],type='l');points(1:1000,x[,2],col='red',type='l')
cor.test(x[2:nrow(x),1],x[1:(nrow(x)-1),2])

laggedcorrs = getLaggedCorrs(x[,1],x[,2],10)

ar=array(data = c(diag(3),c(0,0,0,-1,0,0,0,0,0)),dim = c(3,3,2))
x=marima.sim(kvar=3,ar.model = ar,nsim=10000)
plotLaggedCorrs(x)

ar=array(data = c(diag(4),runif(16,-0.5,0.5)),dim = c(4,4,2))
x=marima.sim(kvar=4,ar.model = ar,nsim=10000,averages = rep(0,2))
plotLaggedCorrs(x,taumax = 10)
eigen(ar[,,2])$values

ar=array(data = c(diag(3),runif(9,-0.5,0.5)),dim = c(3,3,2))
x=marima.sim(kvar=3,ar.model = ar,nsim=10000,averages = rep(0,3))
plotLaggedCorrs(x,taumax = 20)




