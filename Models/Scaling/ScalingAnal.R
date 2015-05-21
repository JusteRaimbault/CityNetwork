
#########
## Verif of analytical derivations for scaling sensitivity


# generate a vector of radiuses
ri <- function(Pmax,d0,alpha,N){
  return(sqrt(Pmax/(2*pi*d0)*(1:N)^(-alpha)))
}
# not used ?

# P_i(\theta)
pi <- function(Pmax,d0,alpha,theta,N){
  return(Pmax*(1:N)^(-alpha)*(1-log(theta/d0)*theta/d0 - theta/d0))
}

# A_i(\theta)
ai <- function(Pmax,d0,alpha,theta,lambda,beta,N){
  return(lambda/beta^2*d0^(beta-1)*Pmax*(1:N)^(-alpha)*(1-log(theta/d0)*(theta/d0)^beta - (theta/d0)^beta))
}


Pmax = 1000
d0=100
alpha=1.3
lambda=1
beta=1.2
theta=10
N=100

plot(log(pi(Pmax,d0,alpha,theta,N)),log(ai(Pmax,d0,alpha,theta,lambda,beta,N)))


scalExp <- function(theta){
  x=log(pi(Pmax,d0,alpha,theta,N))
  y=log(ai(Pmax,d0,alpha,theta,lambda,beta,N))
 lm(x~y)$coefficients[2]
}




