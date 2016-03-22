
# tests

entropy <- function(x){
  ptot = sum(x)
  N = length(x)
  return(-1 / log(N) * sum(x/ptot*log(x/ptot)))
}


n = 1000000
x=(runif(n) - runif(n));y=(runif(n) - runif(n))
hist(sqrt(x*x + y*y),breaks=1000)
mean(sqrt(x*x + y*y))
