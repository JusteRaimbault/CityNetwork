
# statistical tests on synthetic data

library(dplyr)
library(ggplot2)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/Statistics/Synthetic/'))

list.files('rdb')

d=as.tbl(read.csv("rdb/06_19_29.714_PM_02-juin-2016.csv",sep=";"))
#d=as.tbl(read.csv("rdb/05_46_43.391_PM_02-juin-2016.csv",sep=";"))
#d=d[d$t>40,]

#d %>% group_by(x,y) %>% summarise(deltad = density[1:(length(density)-1)]-density[2:length(density)])
# 
deltad = data.frame()
for(t in (min(d$t)+5):max(d$t)){
   deltad=rbind(deltad,cbind(d[d$t==t,4:7]-d[d$t==t-1,4:7],t=rep(t,length(which(d$t==t)))))
}

# 
# ###
# ## small test on ts clustering
# data = data.frame(deltad[deltad$t==2,1:4])
# for(t in (min(deltad$t)+1):max(deltad$t)){
#   data=cbind(data,deltad[deltad$t==t,1:4])
# }
# 
# data = data.frame(d[d$t==2,4:7])
# for(t in (min(d$t)+1):max(d$t)){
#   data=cbind(data,d[d$t==t,4:7])
# }
# 
# km=kmeans(data,2,nstart = 10,iter.max = 10000)
# centers=km$centers
# 
# plot(centers[1,seq(from=2,to=ncol(centers),by=4)],type='l')
# plot(centers[2,seq(from=2,to=ncol(centers),by=4)],type='l',col='red')
# 
# x=centers[2,seq(from=9,to=ncol(centers),by=4)]
# y=centers[2,seq(from=10,to=ncol(centers),by=4)]
# x=(x-min(x))/(max(x)-min(x));y=(y-min(y))/(max(y)-min(y))
# 
# plot(x,type='l');points(y,type='l',col='red')

# NO NEED TO NORMALIZE, EXACTLY THE SAME AS WORK ON CORRELATIONS
#deltad$density=deltad$density/max(abs(deltad$density))
#deltad$cdistance=deltad$cdistance/max(abs(deltad$cdistance))

# second order
#ddeltad = data.frame()
#for(t in 3:max(deltad$t)){
#  ddeltad=rbind(ddeltad,cbind(deltad[deltad$t==t,]-deltad[deltad$t==t-1,],t=rep(t,length(which(deltad$t==2)))))
#}


# plot the variables in time
#deltad=deltad[deltad$density!=0&deltad$cdistance!=0,]
#dd1=cbind(deltad[,c(1,5)],var=rep("∆density",nrow(deltad)));names(dd1)<-c("var","t","varname")
#dd2=cbind(deltad[,c(2,5)],var=rep("∆dcenter",nrow(deltad)));names(dd2)<-c("var","t","varname")

#g=ggplot(rbind(dd1,dd2),aes(x=t,y=var,colour=varname))
#g+geom_point(pch='+',cex=2)+stat_smooth(method = "loess",span=0.3)+ylim(-0.3,1.0)


# compute lagged correlation : -15:15
laggedcors=data.frame()
n=length(which(deltad$t==min(deltad$t)))
for(tau in 0:15){
  x=deltad$density[1:(nrow(deltad)-(n*tau))];y=deltad$cdistance[((n*tau)+1):nrow(deltad)]
  rho=cor.test(x[x!=0&y!=0],y[x!=0&y!=0])
  #rho=cor.test(x,y)
  laggedcors=rbind(laggedcors,data.frame(tau,rho=rho$estimate,rhomin=rho$conf.int[1],rhomax=rho$conf.int[2]))
}
for(tau in 1:15){
  x=deltad$cdistance[1:(nrow(deltad)-(n*tau))];y=deltad$density[((n*tau)+1):nrow(deltad)]
  rho=cor.test(x[x!=0&y!=0],y[x!=0&y!=0])
  #rho=cor.test(x,y)
  laggedcors=rbind(laggedcors,data.frame(tau=-tau,rho=rho$estimate,rhomin=rho$conf.int[1],rhomax=rho$conf.int[2]))
}

g=ggplot(laggedcors,aes(x=tau,y=rho))
g+geom_point()+geom_errorbar(aes(ymin=rhomin,ymax=rhomax))+stat_smooth(method = "loess",span=0.7)




# 
#dd=as.tbl(ddeltad[,c(1:4,6)])%>%group_by(t)%>%summarise(density=mean(density),cdistance=mean(cdistance))
#laggedcors=data.frame()
#for(tau in 0:15){
#  rho=cor.test(dd$density[1:(nrow(dd)-(tau))],dd$cdistance[(tau+1):nrow(dd)])
#  laggedcors=rbind(laggedcors,data.frame(tau,rho=rho$estimate,rhomin=rho$conf.int[1],rhomax=rho$conf.int[2]))
#}
#for(tau in 1:15){
#  rho=cor.test(dd$cdistance[1:(nrow(dd)-(tau))],dd$density[(tau+1):nrow(dd)])
#  laggedcors=rbind(laggedcors,data.frame(tau=-tau,rho=rho$estimate,rhomin=rho$conf.int[1],rhomax=rho$conf.int[2]))
#}





