
## wrapper of exploration job to be used as SystemExecTask from openmole

# read command line args
args <- commandArgs(trailingOnly = TRUE)

setwd(paste0(Sys.getenv("CN_HOME"),'/Models/Scaling'))
source('ScalingSensitivity.R')
source('ScalingAnal.R')

# Parameters
WorldWidth = 400
Pmax = 10000
d0=100 # in case constant
r0=4 # idem
alpha=1.3
lambda=1
N=15

kernel_type = "poisson"

Nrep_emp = 10

b = as.numeric(args[2])
theta = as.numeric(args[1])

th = scalExp(theta,b);

empvals=c()

for(k in 1:Nrep_emp){
    d=spatializedExpMixtureDensity(WorldWidth,N,r0,r0,Pmax,alpha,0.001);
    empvals=append(empvals,empScalExp(theta,lambda,b,d))
}

emp=mean(empvals);
empsd=sd(empvals);

write.csv(data.frame(th,emp,empsd),file="temp_")



