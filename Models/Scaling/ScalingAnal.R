
#########
## Verif of analytical derivations for scaling sensitivity


# generate a vector of radiuses (constant density)
ri <- function(Pmax,d0,alpha,N){
  return(sqrt(Pmax/(2*pi*d0)*(1:N)^(-alpha)))
}
# not used ?

# generate a vector of densities (constant radius)
di <- function(Pmax,r0,alpha,N){
  return(Pmax/(2*pi*r0^2)*(1:N)^(-alpha))
}

# P_i(\theta)
pop <- function(ri,di,theta){
  return(2*pi*di*ri^2*(1+log(theta/di)*theta/di - theta/di))
}

# A_i(\theta)
ai <- function(ri,di,theta,lambda,beta){
  return(lambda/beta^2*2*pi*di^beta*ri^2*(1+log(theta/di)*(theta/di)^beta - (theta/di)^beta))
}


#Pmax = 1000000
#d0=100
#r0=10
#alpha=1.3
#lambda=1
#beta=10
#theta=10^(-3)
#N=100

#plot(log(pop(r0,di(Pmax,r0,alpha,N),theta)),log(ai(r0,di(Pmax,r0,alpha,N),theta,lambda,beta)))


# scaling exponent (computed empirically via lm) as a function of theta,beta
scalExp <- function(theta,beta){
  x=log(pop(r0,di(Pmax,r0,alpha,N),theta))
  y=log(ai(r0,di(Pmax,r0,alpha,N),theta,lambda,beta))
 return(lm(y~x)$coefficients[2])
}

# not needed, use sapply(x,fun,...)
scalExpBeta <- function(theta){
  return(scalExp(theta,beta))
}

#thetas = 10^(seq(from=-5,to=-1,by=0.05))
#sapply(thetas,scalExp,beta)

#beta = 10
#plot(thetas,sapply(thetas,scalExp,beta))

#########
# Plot alpha(theta) for different betas
library(ggplot2)
#thetas = 10^(seq(from=-2,to=-0.2,by=0.01))
#thetas = 1:10
#betas = seq(from=1.05,to=1.5,by=0.05)

#theta=c();scaling.exp=c();beta=c();
#for(b in betas){
#  beta=append(beta,rep(b,length(thetas)));
#  theta=append(theta,thetas);
#  scaling.exp=append(scaling.exp,sapply(thetas,scalExp,b))
#}

# plot
#ggplot(data.frame(theta,scaling.exp,beta),aes(x=theta,y=scaling.exp,colour=beta)) + geom_line(aes(group=beta))




