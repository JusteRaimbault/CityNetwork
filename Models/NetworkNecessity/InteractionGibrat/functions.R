

# functions


loadData<-function(Ncities){
  # load ined file
  raw <- as.tbl(read.csv(paste0(Sys.getenv('CN_HOME'),'/Data/INED/VIL1831.csv'),sep=";",stringsAsFactors = FALSE))
  
  # filter on continuity of data
  rows=rep(TRUE,nrow(raw));for(j in 19:49){rows = rows&(!is.na(as.numeric(raw[[colnames(raw)[j]]])))}
  raw = raw[rows,]
  for(j in 19:49){raw[,j]<-as.numeric(raw[[colnames(raw)[j]]])}
  raw = raw %>% arrange(desc(P1999))
  #Ncities = 50
  cities = raw[1:Ncities,c(5:7,19:49)]
  dates = c(seq(from=1831,to=1866,by=5),1872,seq(from=1876,to=1911,by=5),1912,seq(from=1921,to=1936,by=5),1946,1954,1955,1962,1968,1975,1982,1990,1999)

  ## distance matrix
  distances = spDists(as.matrix(cities[,2:3]))/10
  
  return(list(cities=cities,dates=dates,distances=distances))
}



potentials <-function(populations,distances,gammaGravity,decayGravity){
  ptot = sum(populations)
  res = diag((populations/ptot)^gammaGravity)%*%exp(-distances / decayGravity)%*%diag((populations/ptot)^gammaGravity)
  diag(res) <- 0
  return(res)
}


gibratModel <- function(real_populations,growthRate){
  populations = matrix(0,nrow(real_populations),ncol(real_populations))
  populations[,1] = real_populations[,1]
  pflat=real_populations[,1];
  tflat=rep(1,nrow(real_populations));
  cflat=1:nrow(real_populations);
  realflat = real_populations[,1]
  for(t in 2:ncol(real_populations)){
    populations[,t] = populations[,t-1]*(1 + growthRate)
    pflat=append(pflat, populations[,t]);tflat=append(tflat,rep(t,Ncities));cflat=append(cflat,1:Ncities)
    realflat=append(realflat,real_populations[,t])
  }
  return(list(df=data.frame(populations = pflat,real_populations=realflat,times=tflat,cities=cflat),
              populations=populations
        )
  )
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


