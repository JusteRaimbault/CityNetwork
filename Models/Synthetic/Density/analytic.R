library(ggplot2)
library(dplyr)


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


res<-sim1dprefAttDiff(c(rep(0,100),1,rep(0,100)),0.5,0.1,10,100000)
plot(1:ncol(res),res[nrow(res),],type='l')


res<-sim1dprefAttDiff(c(rep(0,100),1,rep(0,100)),0.5,0.1,10,1000000,timesample=1000)
g=ggplot(res[res$t>2000,],aes(x=x,y=p,colour=t,group=t))
g+geom_line()#+scale_y_log10()

res<-sim1dprefAttDiff(c(rep(0,10000),1,rep(0,10000)),0.5,0.1,10,100000,timesample=10000)
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

g=ggplot(res%>%group_by(t)%>%summarise(pop=sum(y)),aes(x=t,y=c(0,diff(pop))))
g+geom_line()


res<-sim1dprefAttDiff(c(rep(0,50),rep(1,100)/100,rep(0,50)),2.4,0.001,10,1000000,timesample=1000,random = F)
g=ggplot(res[res$t>2000,],aes(x=x,y=p,colour=t,group=t))
g+geom_line()


# deterministic
res<-sim1dprefAttDiff(c(rep(0,50),1,rep(0,100),1,rep(0,50)),2.4,0.001,10,100000,timesample=1000,random = F)
g=ggplot(res[res$t>2000,],aes(x=x,y=p,colour=t,group=t))
g+geom_line()








