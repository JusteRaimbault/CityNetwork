library(ggplot2)

n=100000

p0 = rlnorm(n)
p0=runif(n)

growthRates<-function(){rnorm(n,mean=1,sd = 0.05)}

nextDistrib <- function(p){sample(growthRates()*p,n)}

pops=p0;times=rep(0,n)
p=p0
for(t in 1:100){
  p=nextDistrib(p)
  pops=append(pops,p);times=append(times,rep(t,n))
  show(mean(p))
}


g=ggplot(data.frame(pops,times))
g+geom_density(aes(x=pops,colour=as.character(times)),show.legend=FALSE)+xlim(c(-2,20))
