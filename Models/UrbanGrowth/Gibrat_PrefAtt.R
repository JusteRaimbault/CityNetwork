
########################
## Numerical Simulations to check link between Gibrat and Pref Att Models
########################


#########
# returns a matrix representing a realization of gibrat trajectories
#  with a log-normal law (1+logn(mu,sigma))
#  given :
#   - final time t
#   - Initial distribs
#   - mean growth rates : can be a function of prec. expected pop values and time, a scalar, a column vector, a line vector, or a matrix.
#   - std of growth rates : scalar (fixed in time and space ?) -> to be generalized
gibrat<- function(t,P0,growth,sigma){
   N = length(P0)
   if(is.function(growth)){rates = matrix(0,t,N)}# function : will be filled progressively
   else if(length(growth)==1){rates = matrix(growth,t,N)}#scalar
   else if(prod(dim(growth)==c(t,1))){rates=matrix(data=rep(growth,N),nrow=t)}
   else if(prod(dim(growth)==c(1,N))){rates=matrix(data=rep(growth,t),nrow=t,byrow=TRUE)}
   else if(prod(dim(growth)==c(t,N))){rates=growth}
   else{stop("wrong growth input")}
   
   # now iterate in time
   res = matrix(0,(t+1),N)
   res[1,]=P0
   
   for(tt in 2:(t+1)){
     # compute growth if needed
     if(is.function(growth)){}
     res[tt,] = res[tt-1,] * (1+rlnorm(N,meanlog=log(rates[tt-1,]),sdlog=sigma))
   }
   return(res)
}



# test it
# power law
trajs = gibrat(10000,rep(1,100),0.0001,0.5)
plot(log(1:100),log(sort(trajs[10001,],decreasing=TRUE)))

# in mean
trajs=rep(0,100)
Nrep=200
for(i in 1:Nrep){
  show(i)
  trajs = trajs+gibrat(100000,rep(1,100),0.0001,0.5)[100001,]
}
plot(log(1:100),log(sort(trajs/Nrep,decreasing=TRUE)))







###################
## Numerical derivations of pref att
###################

prefAtt<-function(t,P0,lambda,m){
  N = length(P0)
  res = matrix(0,t+1,N)
  res[1,]=P0
  Ptot=sum(P0)
  for(tt in 2:(t+1)){
    res[tt,]=res[tt-1,]
    for(i in 1:m){
      if(runif(1)<lambda){
        #choose one site
        p = runif(1);s=0
        for(j in 1:N){
          s = s + (res[tt-1,j]/Ptot)
          if(p<s){res[tt,j]=res[tt,j]+1;break}
        }
      }
    }
    Ptot=sum(res[tt,])
  }
  return(res)
}

#test
trajs = prefAtt(1000,rep(1,50),0.01,1000)
plot(log(1:50),log(sort(trajs[1001,],decreasing=TRUE)))

# clearly same mechanism !

# TODO : small param space explo.

# now compare expected values
expectedPrefAtt<-function(t,P0,lambda,m){
  N=length(P0)
  res = matrix(0,t+1,N)
  res[1,]=P0
  for(tt in 2:(t+1)){
    # compute q
    q = res[tt-1,] / ((P0 / lambda) + m*(tt-2)) 
    # exact value
    res[tt,] = (res[tt-1,] * (1 - q^(m+1)) / (1-q)) + ((q*(q^(m+1)-1)+(m+1)*q^m*(1-q))/((1 - q)^2))
  }
  return(res)
}

plot(expectedPrefAtt(100,10,0.001,100))

# check existence of an exponential rate
t=10000;P0=10;lambda=0.001;m=10;
expect = expectedPrefAtt(t,P0,lambda,m)
plot(400:t,log(expect/P0)[400:t])

# Q : if comp ok : sensitivity of distrib to initial distrib ?
# theoretically hierarchy should be conserved ?
# but asymptotic expected sizes should be all the same ? (symmetry of the model ?)
# ... to be investigated.











