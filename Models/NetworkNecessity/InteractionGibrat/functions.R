

# functions


potentials <-function(populations,distances,gammaGravity,decayGravity){
  ptot = sum(populations)
  res = diag((populations/ptot)^gammaGravity)%*%exp(-distances / decayGravity)%*%diag((populations/ptot)^gammaGravity)
  diag(res) <- 0
  return(res)
}



interactionModel <- function(real_populations,distances,gammaGravity=0,decayGravity=1,growthRate=0,potentialWeight=1){
  populations = matrix(0,nrow(real_populations),ncol(real_populations))
  populations_gibrat = matrix(0,nrow(real_populations),ncol(real_populations))
  populations[,1] = real_populations[,1]
  populations_gibrat[,1] = real_populations[,1]
  pflat=real_populations[,1];
  pgflat=real_populations[,1];
  tflat=rep(1,nrow(real_populations));
  cflat=1:nrow(real_populations);
  realflat = real_populations[,1]
  for(t in 2:ncol(real_populations)){
    pot = potentials(populations[,t-1],distances,gammaGravity,decayGravity)
    populations[,t] = populations[,t-1]*(1 + growthRate + pot%*%matrix(rep(1,nrow(pot)),nrow=nrow(pot))/potentialWeight)
    populations_gibrat[,t] = populations_gibrat[,t-1]*(1 + growthRate)
    pflat=append(pflat, populations[,t]);pgflat=append(pgflat, populations_gibrat[,t]);tflat=append(tflat,rep(t,Ncities));cflat=append(cflat,1:Ncities)
    realflat=append(realflat,real_populations[,t])
  }
  return(list(df=data.frame(populations = pflat,gibrat_populations=pgflat,real_populations=realflat,times=tflat,cities=cflat),
              populations=populations,
              gibrat_populations=populations_gibrat
              )
  )
}


