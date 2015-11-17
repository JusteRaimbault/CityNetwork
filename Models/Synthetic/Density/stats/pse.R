
# first pse results viz for density gen model

pse <-read.csv(
  paste0(Sys.getenv("CN_HOME"),'/Results/Synthetic/Density/PSE_tmp/population700.csv'),
  sep=","
)

pse = pse[,2:10]
colnames(pse)[6:9] <- c(indics)

par(mfrow=c(1,2))
plot(pse)
plot(m[,c(3,1,2,5)])

col_par_name="diffusion"
plots=list()
k=1
#par(mfrow=c(2,3))
for(i in 1:3){
  for(j in (i+1):4){
    plots[[k]]=plotPoints(pse,med,indics[i],indics[j],col_par_name)
    k=k+1
  }
}

multiplot(plotlist=plots,cols=3)


# try prcomp on pse res ?
for(j in 1:ncol(pse)){pse[,j]=(pse[,j]-min(pse[,j]))/(max(pse[,j])-min(pse[,j]))}
summary(prcomp(pse))


##
# try to study bounds

# ex : entropy >= f(Moran) ?

g = plotPoints(pse,med,"moran","entropy","diffusion")
fit = data.frame(x=(0:100)/300,s=((0:100)/300)^0.4)
g+geom_point(data=fit,aes(x=x,y=s),colour="green")

# fit the lower bound of entropy = f(moran)
# take pareto front of pse
x=(0:100)/300
bound=c()
for(i in 1:(length(x)-5)){
  m=min(pse[pse$moran>x[i]&pse$moran<x[i+1],8])
  if(m==Inf){m=NA}
  bound = append(bound,m)
}

# fit log
d=data.frame(x=log(x[2:length(bound)]),y=log(bound[2:length(bound)]))
coefs=summary(lm(y~x,d))$coefficients
beta=exp(coefs[1,1])
alpha=coefs[2,1]

fit = data.frame(x=(1:100)/300,s=beta*((1:100)/300)^alpha)
g+geom_point(data=fit,aes(x=x,y=s),colour="green")


# idem for entropy <= f(distance) ?
g = plotPoints(pse,med,"distance","entropy","diffusion")

x = (2:95)/100
bound=c()
for(i in 1:(length(x)-1)){
  m=max(pse[pse$distance>x[i]&pse$distance<x[i+1],8])
  #if(m==Inf){m=NA}
  bound = append(bound,m)
}
coefs=summary(lm(y~x,data.frame(x=log(x[1:length(bound)]),y=log(bound[1:length(bound)]))))$coefficients
fit = data.frame(x=x,s=exp(coefs[1,1])*x^coefs[2,1])
g+geom_point(data=fit,aes(x=x,y=s),colour="green")
