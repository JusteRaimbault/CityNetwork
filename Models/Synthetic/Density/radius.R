setwd(paste0(Sys.getenv("CN_HOME"),'/Models/Synthetic/Density'))

sim1dprefAttDiff<-function(x0,alpha,beta,growth,t,nd=1,timesample=0,random=T){
  res<-x0
  tres=data.frame(t=rep(0,length(x0)),x=1:length(x0),y=x0,p=x0/sum(x0))
  for(t in 2:(t+1)){
    tmp = res
    if(random==T){
      for(k in sample(1:length(x0),size=growth,replace = T,prob=tmp^alpha/sum(tmp^alpha))){
        tmp[k]<-tmp[k]+1
      }
    }else{
      tmp = tmp + (tmp^alpha/sum(tmp^alpha))*growth
    }
    res=tmp*(1-beta) + beta/2*(c(tmp[2:length(tmp)],0)+c(0,tmp[1:(length(tmp)-1)]))
    if(timesample>0&t%%timesample==0){show(t);tres=rbind(tres,data.frame(t=rep(t,length(x0)),x=1:length(x0),y=res,p=res/sum(res)))}
  }
  if(timesample==0){return(res)}
  else{return(tres)}
}

getRadius<-function(alpha,beta){
  sim<-sim1dprefAttDiff(c(rep(0,10000),1,rep(0,10000)),alpha,beta,10,100000,timesample=20000)
  vals = sim$p[sim$t==max(sim$t)&sim$x>10000]
  return(which(cumsum(vals)>0.99*sum(vals))[1])
}

params = data.frame()
for(alpha in seq(from=0.5,to=2.5,by=0.1)){
  for(logbeta in seq(from=-3,to=-0.5,by=0.2)){
    params=rbind(params,data.frame(alpha=alpha,beta=10^logbeta))
  }
}


library(doParallel)
cl <- makeCluster(50,outfile='log')
registerDoParallel(cl)

startTime = proc.time()[3]

res <- foreach(i=1:nrow(params)) %dopar% {
   alpha = params[i,1];beta=params[i,2]
   return(getRadius(alpha,beta))
}

save(res,file='res/radius.RData')



