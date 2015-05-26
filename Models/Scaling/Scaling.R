
#########
# Result Synthesis for Scaling Sensitivity
#########


# source functions
setwd(paste0(Sys.getenv("CN_HOME"),'/Models/Scaling'))
source('ScalingSensitivity.R')
source('ScalingAnal.R')

# libraries
library(ggplot2)


# Parameters
WorldWidth = 400
Pmax = 10000
d0=100 # in case constant
r0=4 # idem
alpha=1.3
lambda=1
beta=10
theta=10^(-3)
N=15

# single run
#emp = empScalExp(spatializedExpMixtureDensity(WorldWidth,N,r0,r0,Pmax,alpha,theta),theta,lambda,beta)
#th = scalExp(theta,beta)


# Multiple curves
kernel_type = "gaussian"

thetas = 10^(seq(from=-3,to=-1,by=0.1))
betas = seq(from=1.05,to=1.5,by=0.05)

Nrep_emp = 10

theta=c();emp=c();empsd=c();th=c();beta=c();
for(b in betas){
  show(b)
  beta=append(beta,rep(b,length(thetas)));
  theta=append(theta,thetas);
  th=append(th,sapply(thetas,scalExp,b));
  # compute empirical
  empvals=matrix(0,Nrep_emp,length(thetas))
  for(k in 1:Nrep_emp){
    show(k)
    d=spatializedExpMixtureDensity(WorldWidth,N,r0,r0,Pmax,alpha,0.001,kernel_type);
    empvals[k,]=sapply(thetas,empScalExp,lambda,b,d)
  }
  emp=append(emp,apply(empvals,2,mean));empsd=append(empsd,apply(empvals,2,sd))
}



# save data
d = data.frame(theta,emp,empsd,th,beta)
write.csv(d,file=paste0("res/emp-th_expl_",date(),".csv"))

# draw the plot using ggplot

# 1) Th/emp
#p = ggplot(data.frame(theta,emp,empsd,th,beta),aes(x=theta,y=emp))+ geom_point(aes(x=theta,y=emp,colour=beta,group=beta))+ geom_line(aes(x=theta,y=th,colour=beta,group=beta)) 
#    p + geom_errorbar(aes(y=emp,ymin=emp-empsd, ymax=emp+empsd,colour=beta),width=0.001) 

#+ ggtitle("")
     #+ xlab("") + ylab("")


# 2) Idem with varying density and radius - th not needed
#ggplot(data.frame(theta,emp,empsd,beta))
#+ geom_points(aes(x=theta,y=emp,colour=beta,group=beta))
#+ geom_errorbar(aes(ymin=emp-empsd, ymax=emp+empsd,colour=beta), width=.01) + 
#  + ggtitle("")
#+ xlab("") + ylab("")


# 3) same as 1) but data with different kernels

# 4) TODO : two params phase diagram -> superpose two fields, actives density and employment.








