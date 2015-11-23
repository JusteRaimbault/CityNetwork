
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






