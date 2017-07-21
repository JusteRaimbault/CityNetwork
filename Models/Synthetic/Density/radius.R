setwd(paste0(Sys.getenv("CN_HOME"),'/Models/Synthetic/Density'))

sim1dprefAttDiff<-function(x0,alpha,beta,growth,t,nd=1,timesample=0,random=T,withDiffs=F){
  res<-x0
  tres=data.frame(t=rep(0,length(x0)),x=1:length(x0),y=x0,p=x0/sum(x0))
  if(withDiffs){tres=cbind(tres,data.frame(dx=rep(0,nrow(tres)),dt=rep(0,nrow(tres)),dtproba=rep(0,nrow(tres))))}
  for(t in 1:t){
    tmp = res
    if(withDiffs){prevres=res}
    if(random==T){
      for(k in sample(1:length(x0),size=growth,replace = T,prob=tmp^alpha/sum(tmp^alpha))){
        tmp[k]<-tmp[k]+1
      }
    }else{
      tmp = tmp + (tmp^alpha/sum(tmp^alpha))*growth
    }
    res=tmp*(1-beta) + beta/2*(c(tmp[2:length(tmp)],0)+c(0,tmp[1:(length(tmp)-1)]))
    if(timesample>0&t%%timesample==0){
      currentdata=data.frame(t=rep(t,length(x0)),x=1:length(x0),y=res,p=res/sum(res))
      if(withDiffs){
        Palpha=sum(res^alpha)
        dx = c(0,diff(res));dx2 = c(0,diff(dx))
        dxterm = ng*res^alpha/Palpha + alpha*beta*(alpha - 1)/2*ng*res^(alpha-2)/Palpha*dx^2 + beta/2*dx2*(1 + alpha*ng*res^(alpha-1)/Palpha)
        dtterm = res - prevres;dtproba=res/sum(res) - prevres/sum(prevres)
        currentdata=cbind(currentdata,dx=dxterm,dt=dtterm,dtproba=dtproba)
      }
      show(t);tres=rbind(tres,currentdata)
    }
  }
  if(timesample==0){return(res)}
  else{return(tres)}
}

getRadius<-function(alpha,beta){
  sim<-sim1dprefAttDiff(c(rep(0,10000),1,rep(0,10000)),alpha,beta,10,100000,timesample=20000,random = F)
  vals = sim$p[sim$t==max(sim$t)&sim$x>10000]
  return(which(cumsum(vals)>0.99*sum(vals))[1])
}

getPmax<-function(alpha,beta){
  sim<-sim1dprefAttDiff(c(rep(0,100),1,rep(0,100)),alpha,beta,10,1000000,timesample=10000,random = F)
  return(max(sim$p[sim$t==max(sim$t)]))
}

params = data.frame()
for(alpha in seq(from=0.4,to=1.5,by=0.025)){
  for(logbeta in seq(from=-4,to=-0.5,by=0.1)){
    params=rbind(params,data.frame(alpha=alpha,beta=10^logbeta))
  }
}


library(doParallel)
cl <- makeCluster(50,outfile='log')
registerDoParallel(cl)

startTime = proc.time()[3]

res <- foreach(i=1:nrow(params)) %dopar% {
  show(paste0(i,'/',nrow(params)))
   alpha = params[i,1];beta=params[i,2]
   return(getPmax(alpha,beta))
   #return(getRadius(alpha,beta))
}

#save(res,file='res/radius_deterministic.RData')
save(res,file='res/pmax.RData')


###
# load('res/radius_deterministic.RData')
# library(ggplot2)
# 
# d = data.frame(params,radius=unlist(res))
# g=ggplot(d,aes(x=log(alpha),y=log(radius),colour=beta,group=beta))
# g+geom_line()
# 
# g=ggplot(d[d$alpha>1,],aes(x=log(beta),y=log(radius),colour=alpha,group=alpha))
# g+geom_line()
# 
# fit=data.frame()
# for(alpha in unique(d$alpha)){
#   reg = lm(lradius~lbeta,data.frame(lbeta=log(d$beta[d$alpha==alpha]),lradius=log(d$radius[d$alpha==alpha])))
#   summary(reg)$adj.r.squared
#   fit=rbind(fit,data.frame(k=reg$coefficients[1],ksd=summary(reg)$coefficients[1,2],p=reg$coefficients[2],psd=summary(reg)$coefficients[2,2],rsq=summary(reg)$adj.r.squared,alpha=alpha))
# }
# 
# g=ggplot(fit,aes(x=alpha,y=k,ymin=k-ksd,ymax=k+ksd))
# g+geom_line()+geom_errorbar()
# 
# g=ggplot(fit,aes(x=alpha,y=log(-(log(k)/k-log(fit$k[nrow(fit)])/fit$k[nrow(fit)]))))
# g+geom_line()+stat_smooth(span=2)
# 
# g=ggplot(fit,aes(x=alpha,y=p))
# g+geom_line()+geom_errorbar(ymin=fit$p-fit$psd,ymax=fit$p+fit$psd)+stat_smooth(span = 0.4)+ylim(c(0.469,0.5))
# 
# g=ggplot(fit,aes(x=alpha,y=rsq))
# g+geom_line()
# 


####
## pmax
load('res/pmax.RData')
library(ggplot2)
resdir=paste0(Sys.getenv('CN_HOME'),'/Results/Synthetic/Density/Analytic/')
d = data.frame(params,pmax=unlist(res))

g=ggplot(d,aes(x=alpha,y=pmax,color=beta,group=beta))
g+geom_line()+stdtheme
ggsave(paste0(resdir,'pmax_alpha.png'),width=15,height=10,units='cm')

g=ggplot(d,aes(x=log(beta),y=pmax,color=alpha,group=alpha))
g+geom_line()+stdtheme
ggsave(paste0(resdir,'pmax_logbeta.png'),width=15,height=10,units='cm')

#g=ggplot(d[log(d$beta)>-5,],aes(x=log(beta),y=pmax,color=alpha,group=alpha))
#g+geom_line()


