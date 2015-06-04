
########
## Parallel computing tests
########

library(doParallel)
cl <- makeCluster(4)
registerDoParallel(cl)

r <- foreach(icount(100), .combine=cbind) %dopar% {
   lm(x~y,data.frame(x=rnorm(100000),y=rnorm(100000)))$coefficients
}


