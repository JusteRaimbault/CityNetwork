

## empirical analyses of spatio-temporal correlations

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
corrs=c();years=c();dists=c()
for(t in 1:length(t0)){
  current_dates = t0[t]:(t0[t]+10);pops = as.matrix(cities[,current_dates+3])
  

# correlations between time-series
# (hyp : different processes, independant in time)
s = pops
for(j in 1:ncol(pops)){s[,j]=s[,j]/pops[,1]}
delta_x = log(s[,2:ncol(s)]) - log(s[,1:(ncol(s)-1)])

# fill correlation matrix
rho = matrix(0,Ncities,Ncities)

localcorrs=c();localdists=c()
for(i in 1:(Ncities-1)){show(i);for(j in (i+1):Ncities){
  r = cor(as.numeric(delta_x[i,]),as.numeric(delta_x[j,]))
  rho[i,j]=r;rho[j,i]=r
  localcorrs = append(localcorrs,r);localdists=append(localdists,distances[i,j])
}}
diag(rho)<-1

corrs = append(corrs,localcorrs);dists=append(dists,localdists)
years=append(years,rep(dates[current_dates[length(current_dates)]],Ncities*(Ncities-1)/2))
}

g = ggplot(data.frame(corrs=corrs,d=dists,year=as.character(years)),aes(x=d,y=corrs,colour=year))
g+geom_smooth()+xlab("distance")+ylab("correlations")




