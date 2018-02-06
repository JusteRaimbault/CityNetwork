library(ggplot2)
library(dplyr)

resdir=paste0(Sys.getenv('CN_HOME'),'/Results/Synthetic/Density/Analytic/')


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


res<-sim1dprefAttDiff(c(rep(0,100),1,rep(0,100)),0.5,0.1,10,100000)
plot(1:ncol(res),res[nrow(res),],type='l')


res<-sim1dprefAttDiff(c(rep(0,100),1,rep(0,100)),0.4,0.0001,10,1000000,timesample=10000,random = T)
g=ggplot(res[res$t>2000,],aes(x=x,y=p,colour=t,group=t))
#g=ggplot(res,aes(x=x,y=p,colour=t,group=t))
g+geom_line()#+scale_y_log10()
plot(diff((as.tbl(res)%>%group_by(t)%>%summarise(pop=sum(y)))$pop),type='l')

res<-sim1dprefAttDiff(c(rep(0,10000),1,rep(0,10000)),0.5,0.2,10,100000,timesample=10000)
g=ggplot(res[res$t>2000,],aes(x=x,y=p,colour=t,group=t))
g+geom_line()

res<-sim1dprefAttDiff(c(rep(0,50),1,rep(0,100),1,rep(0,50)),0.5,0.1,10,100000,timesample=1000)
g=ggplot(res[res$t>2000,],aes(x=x,y=p,colour=t,group=t))
g+geom_line()

res<-sim1dprefAttDiff(c(rep(0,100),1,rep(0,100)),2.4,0.001,10,100000,timesample=1000)
g=ggplot(res[res$t>2000,],aes(x=x,y=p,colour=t,group=t))
g+geom_line()

res<-sim1dprefAttDiff(c(rep(0,50),1,rep(0,100),1,rep(0,50)),2.4,0.001,10,100000,timesample=1000)
g=ggplot(res[res$t>2000,],aes(x=x,y=p,colour=t,group=t))
g+geom_line()
# !! -> has not converged !!
res<-sim1dprefAttDiff(c(rep(0,50),1,rep(0,100),1,rep(0,50)),2.4,0.001,10,10000000,timesample=100000)
g=ggplot(res[res$t>2000,],aes(x=x,y=p,colour=t,group=t))
g+geom_line()

g=ggplot(res%>%group_by(t)%>%summarise(pop=sum(y)),aes(x=t,y=c(0,diff(pop))))
g+geom_line()


res<-sim1dprefAttDiff(c(rep(0,50),rep(1,100)/100,rep(0,50)),2.4,0.001,10,1000000,timesample=1000,random = F)
g=ggplot(res[res$t>2000,],aes(x=x,y=p,colour=t,group=t))
g+geom_line()


# deterministic
res<-sim1dprefAttDiff(c(rep(0,50),1,rep(0,100),1,rep(0,50)),2.4,0.001,10,100000,timesample=1000,random = F)
g=ggplot(res[res$t>2000,],aes(x=x,y=p,colour=t,group=t))
g+geom_line()


# bifurcations


res<-sim1dprefAttDiff(c(rep(c(rep(0,10),rep(1,10),rep(0,10)),5)),1.4,0.1,10,2000,timesample=1)
g=ggplot(res,aes(x=x,y=p,colour=t,group=t))
g+geom_line()

g=ggplot(res,aes(x=t,y=x,fill=cut(p,11)))
g+geom_raster()+scale_fill_brewer(palette = "Spectral",name='proportion')#+stdtheme


# do it for different runs with fixed seeds
res=data.frame()
nseeds=9
for(seed in 1:nseeds){
  set.seed(seed+100)
  res=rbind(res,sim1dprefAttDiff(c(rep(c(rep(0,10),rep(1,10),rep(0,10)),5)),1.4,0.1,10,10000,timesample=10)
)
}
seeds=c();for(seed in 1:nseeds){seeds=append(seeds,rep(seed,nrow(res)/nseeds))}
res$seed = seeds

g=ggplot(res,aes(x=t,y=x,fill=cut(p,11,dig.lab = 1,right=F)))
g+geom_raster()+scale_fill_brewer(palette = "Spectral",name='Proportion',direction = -1)+facet_wrap(~seed)+stdtheme
ggsave(paste0(resdir,'bifurcations.png'),width=30,height=20,units='cm')

# !! must check if indeed stationary !!


#####
# equation verification

# forall (x,t) such that -x_m < x < x_m and t > 0

# manual check
alpha=0.5;beta=0.1;ng=10;
#res<-sim1dprefAttDiff(c(rep(0,1000),1,rep(0,1000)),alpha,beta,ng,1000,timesample = 1,random = F)
#res<-sim1dprefAttDiff(c(rep(1,1000)),alpha,beta,ng,10000000,timesample = 100000,random = F,withDiffs = T)
res<-sim1dprefAttDiff(exp(-(-200:200/40)^2),alpha,beta,ng,100000,timesample = 1000,random = F,withDiffs = T)



g=ggplot(diffs[abs(diffs$dt-diffs$dx)<1e-5,],aes(x=t,y=x,fill=cut(dt-dx,11)))
#g=ggplot(diffs,aes(x=t,y=x,fill=cut(dt-dx,11)))
g+geom_raster()+scale_fill_brewer(palette = "Spectral",direction = -1)

g=ggplot(res[abs(2*(res$dt-res$dx)/(res$dt+res$dx))<0.5,],aes(x=t,y=x,fill=cut(2*(dt-dx)/(dt+dx),11)))
#g=ggplot(res,aes(x=t,y=x,fill=cut(2*(dt-dx)/(dt+dx),11)))
g+geom_raster()+scale_fill_brewer(palette = "Spectral",direction = -1)


plot(diffs$dt[diffs$x==1000&diffs$t>400],type='l');
points(diffs$dx[diffs$x==1000&diffs$t>400],type='l',col='red')
plot(diffs$dt[diffs$x==1000&diffs$t>400]-diffs$dx[diffs$x==1000&diffs$t>400],type='l')



# stationarity ?
alpha=3.5;beta=0.01;ng=10;
res<-sim1dprefAttDiff(exp(-(-200:200/40)^2),alpha,beta,ng,1000000,timesample = 10000,random = F,withDiffs = T)
g=ggplot(res[abs(res$dtproba)<1e-8,],aes(x=t,y=x,fill=cut(dtproba,11)))
g+geom_raster()+scale_fill_brewer(palette = "Spectral")#+stdtheme

g=ggplot(res,aes(x=t,y=x,fill=cut(dt,11)))
g+geom_raster()+scale_fill_brewer(palette = "Spectral")#+stdtheme


g=ggplot(res,aes(x=x,y=y,colour=t,group=t))
g+geom_line()



#####
## 'numerical' proof convergence : facet alpha, beta

res=data.frame()
for(alpha in c(0.5,1.0,1.5)){
  for(lbeta in c(-2,-1.5,-1)){
    beta = 10^lbeta
    show(paste0("alpha=",alpha,',beta=',beta))
    currentres=sim1dprefAttDiff(c(rep(0,100),1,rep(0,100)),alpha,beta,10,1000000,timesample=10000,random = F)
    res=rbind(res,cbind(currentres,data.frame(alpha=rep(alpha,nrow(currentres)),beta=rep(beta,nrow(currentres)))))
  }
}

g=ggplot(res[res$t>2000,],aes(x=x,y=p,colour=t,group=t))
g+geom_line()+facet_grid(alpha~beta,scales='free')+stdtheme
ggsave(paste0(resdir,'stationary.png'),width=30,height=20,units='cm')

sres = res%>%group_by(alpha,beta)%>%filter(t==max(t))%>%summarise(pmax=max(p))

g=ggplot(sres,aes(x=beta,y=pmax,col=alpha,group=alpha))
g+geom_line()
# -> interesting !

