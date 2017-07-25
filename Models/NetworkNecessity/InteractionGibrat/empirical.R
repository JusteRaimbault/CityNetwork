

## empirical analyses of spatio-temporal correlations
setwd(paste0(Sys.getenv('CN_HOME'),'/Models/NetworkNecessity/InteractionGibrat'))

library(ggplot2)
library(MASS)

stdtheme= theme(axis.title = element_text(size = 22), 
                axis.text.x = element_text(size = 15),axis.text.y = element_text(size = 15),
                strip.text = element_text(size=15),
                legend.text=element_text(size=15), legend.title=element_text(size=15))

source('functions.R')

Ncities = 300
d = loadData(Ncities)
cities = d$cities;dates=d$dates;distances=d$distances
pops = cities[,4:ncol(cities)]
delta_p = (pops[,2:ncol(pops)]-pops[,1:(ncol(pops)-1)])/pops[,1:(ncol(pops)-1)]


boxplot(delta_p[,1],at=1,xlim=c(0,ncol(delta_p)))
for(t in 2:ncol(delta_p)){boxplot(delta_p[,t],at=t,add=TRUE)}

###########

#par(mfrow=c(6,5))
pops = as.matrix(cities[,4:ncol(cities)])
for(j in 2:ncol(pops)){
  show(dates[j])
  r = pops[,j]/pops[,j-1]
  delta_p = (pops[,j]-pops[,j-1])/pops[,j-1]
  delta_x = log(r)
  print(cor.test(delta_x,pops[,j]))
  #show(paste0("lognormal ",dates[j],": ",logLik(fitdistr(g,densfun = "lognormal"))))
  #show(paste0("normal ",dates[j],": ",logLik(fitdistr(g,densfun = "normal"))))
  #hist(g,breaks=100,main=dates[j])
}

#  Rq : growth rates fit better lognormal than normal (except during wars)


############


t0 = seq(1,21,by=5)
corrs=c();years=c();dists=c();corrsinf=c();corrssup=c()
returns=c();growthrates =c() 
for(t in 1:length(t0)){
   current_dates = t0[t]:(t0[t]+10);pops = as.matrix(cities[,current_dates+3])
  

  # correlations between time-series
  # (hyp : different processes, independant in time)
  s = pops
  g = s[,2:ncol(s)] / s[,1:(ncol(s)-1)]
  print(fitdistr(as.numeric(unlist(g[g!=1])),densfun = "lognormal"))
  print(fitdistr(as.numeric(unlist(g[g!=1])),densfun = "normal"))
  growthrates=append(growthrates,as.numeric(unlist(g[g!=1])))
  for(j in 1:ncol(pops)){s[,j]=s[,j]/pops[,1]}
  delta_x = log(s[,2:ncol(s)]) - log(s[,1:(ncol(s)-1)])
  #plot(1:ncol(delta_x),delta_x[1,],type='l')
  #for(i in 2:nrow(delta_x)){points(1:ncol(delta_x),delta_x[i,],col=i,type='l')}

  x=as.numeric(unlist(delta_x))
  returns=append(returns,x[x!=0])


  ####
  # Compute correlations between log-returns

  rho = matrix(0,Ncities,Ncities)
  # 
  localcorrs=c();localdists=c();localcorrsinf=c();localcorrssup=c();
  k=1
  for(i in 1:(Ncities-1)){
    show(i)
    for(j in (i+1):Ncities){
      r = cor.test(as.numeric(delta_x[i,]),as.numeric(delta_x[j,]),method="pearson")
      rho[i,j]=r$estimate;rho[j,i]=r$estimate
      #localcorrs = append(localcorrs,r$estimate);
      localcorrs[k]=r$estimate
      #localdists=append(localdists,distances[i,j])
      localdists[k]=distances[i,j]
      #localcorrsinf = append(localcorrsinf,r$conf.int[1]);
      localcorrsinf[k]=r$conf.int[1]
      #localcorrssup = append(localcorrssup,r$conf.int[2]);
      localcorrsinf[k]=r$conf.int[2]
      k=k+1
    }
  }
  diag(rho)<-1
 
  corrs = append(corrs,localcorrs);dists=append(dists,localdists)
  corrsinf=append(corrsinf,localcorrsinf);corrssup=append(corrssup,localcorrssup)
  years=append(years,rep(dates[current_dates[length(current_dates)]],Ncities*(Ncities-1)/2))
  #years=append(years,rep(dates[current_dates[length(current_dates)]],length(g[g!=1])))
}

g = ggplot(data.frame(corrs=corrs,corrsinf=corrsinf,corrssup=corrssup,d=dists,year=as.character(years)))
g+geom_smooth(aes(x=d,y=corrs,colour=year))+
  #geom_smooth(aes(x=d,y=corrsinf,colour=year))+
  #geom_smooth(aes(x=d,y=corrssup,colour=year))+
  xlab("distance")+ylab("correlations")

# histogram of returns
ggplot(data.frame(returns=returns,growthrate=growthrates,year=as.factor(years)), aes(x=growthrate, fill=year)) + geom_density(alpha=.5)#+geom_vline(data=sdat, aes(xintercept=mean,  colour=type),linetype="dashed", size=1)











