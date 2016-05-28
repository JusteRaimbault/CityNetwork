
source('functions.R')

Ncities = 50
d = loadData(Ncities)
cities = d$cities;dates=d$dates;distances=d$distances

# note : optimize on different time segments : better to stay with GA library than try to use openmole ?

for(t0 in seq(1,21,by=5)){
  current_dates = t0:(t0+10)
  show(current_dates)
  real_populations = as.matrix(cities[,current_dates+3])

  pops=interactionModel(real_populations,distances,params[1],params[2],params[3],params[4])$df;
  mse = sum((pops$populations-pops$real_populations)^2)
  
}