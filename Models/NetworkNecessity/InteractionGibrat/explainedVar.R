
# test machine learning techniques to determine effective
# explained variance for a given number of parameters

library(flare)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/NetworkNecessity/InteractionGibrat'))
source('functions.R')

d <- loadData(50)
cities = d$cities

#real_populations = as.matrix(cities[,4:ncol(cities)])

# construct non-linear design matrix aimed at sparse regression

# ex test a nlarma-2
locdesign = function(x){return(data.frame(x[,1],x[,2],x[,1]^2,x[,2]^2,x[,1]*x[,2],x[,1]^3,x[,2]^3))}


t0 = seq(1,21,by=5)

for(i in 1:length(t0)){
  current_dates = t0[i]:(t0[i]+10);real_populations = as.matrix(cities[,current_dates+3])
  
design = locdesign(real_populations[,1:2])
response = real_populations[,3]

for(j in 4:ncol(real_populations)){
  design = rbind(design,locdesign(real_populations[,(j-2):(j-1)]))
  response=append(response,real_populations[,j])
}

lasso = slim(X=as.matrix(design),Y=as.matrix(response),method="lasso",nlambda = 1000,lambda.min.value = 0.00001,verbose=FALSE)
beta = lasso$beta
logerrors=colSums((log(as.matrix(design)%*%beta)-log(matrix(data=rep(response,ncol(beta)),ncol=ncol(beta),byrow = FALSE)))^2)
errors=colSums(((as.matrix(design)%*%beta)-(matrix(data=rep(response,ncol(beta)),ncol=ncol(beta),byrow = FALSE)))^2)

show(paste0('log : ',min(logerrors[which(colSums(beta!=0)<5)]),' ; ',min(errors[which(colSums(beta!=0)<5)])))

}
