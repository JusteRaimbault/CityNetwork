

## empirical analyses of spatio-temporal correlations
library(ggplot2)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/NetworkNecessity/InteractionGibrat'))
source('functions.R')

Ncities = 300
d = loadData(Ncities)
cities = d$cities;dates=d$dates;distances=d$distances

pops = cities[,4:ncol(cities)]

delta_p = (pops[,2:ncol(pops)]-pops[,1:(ncol(pops)-1)])/pops[,1:(ncol(pops)-1)]


boxplot(delta_p[,1],at=1,xlim=c(0,ncol(delta_p)))
for(t in 2:ncol(delta_p)){boxplot(delta_p[,t],at=t,add=TRUE)}



t0 = seq(1,21,by=5)
corrs=c();years=c();dists=c();corrsinf=c();corrssup=c()
for(t in 1:length(t0)){
  current_dates = t0[t]:(t0[t]+10);pops = as.matrix(cities[,current_dates+3])
  

# correlations between time-series
# (hyp : different processes, independant in time)
s = pops
for(j in 1:ncol(pops)){s[,j]=s[,j]/pops[,1]}
delta_x = log(s[,2:ncol(s)]) - log(s[,1:(ncol(s)-1)])

# fill correlation matrix
rho = matrix(0,Ncities,Ncities)

localcorrs=c();localdists=c();localcorrsinf=c();localcorrssup=c();
for(i in 1:(Ncities-1)){show(i);for(j in (i+1):Ncities){
  r = cor.test(as.numeric(delta_x[i,]),as.numeric(delta_x[j,]),method="pearson")
  rho[i,j]=r$estimate;rho[j,i]=r$estimate
  localcorrs = append(localcorrs,r$estimate);localdists=append(localdists,distances[i,j])
  localcorrsinf = append(localcorrsinf,r$conf.int[1]);localcorrssup = append(localcorrssup,r$conf.int[2]);
}}
diag(rho)<-1

corrs = append(corrs,localcorrs);dists=append(dists,localdists)
corrsinf=append(corrsinf,localcorrsinf);corrssup=append(corrssup,localcorrssup)
years=append(years,rep(dates[current_dates[length(current_dates)]],Ncities*(Ncities-1)/2))
}

g = ggplot(data.frame(corrs=corrs,corrsinf=corrsinf,corrssup=corrssup,d=dists,year=as.character(years)))
g+geom_smooth(aes(x=d,y=corrs,colour=year))+
  geom_smooth(aes(x=d,y=corrsinf,colour=year))+
  geom_smooth(aes(x=d,y=corrssup,colour=year))+
  xlab("distance")+ylab("correlations")




