library(raster)

r <- raster("/Users/Juste/Documents/ComplexSystems/CityNetwork/Data/PopulationDensity/raw/bassin_parisien_500x300.tif")
m = as.matrix(r)
m[is.na(m)] <- 0
r = raster(m)

# weight matrix
spatialWeights <- function (N){
  d = (matrix(rep(cumsum(matrix(1,2*N+1,1)),2*N+1),nrow=2*N+1) - N - 1) ^ 2
  w = 1 / sqrt(d + t(d))
  w[w==Inf]=1
  return(w)
}

# Moran with these weights
#Moran(r,w)

# sensitivity of moran to size of weight matrix
morans = c()
N = seq(from=10,to=150,by=10)
for(n in N){
  show(n)
  morans = append(morans,Moran(r,spatialWeights(n)))
}

plot(N,morans)

# compare with null model : uniformaly distributed data
# -> look at Moran on densities ?

# null model : same densities put at random ? ~ not exactly, corresponds to shuffling

# takes a raster and returns uniformally shuffled data
shuffleData <- function(d){
  m = as.matrix(d)
  m[is.na(m)] <- 0
  return(raster(matrix(sample(m),nrow=nrow(m))))
}

Nrep = 10
null_morans = matrix(0,length(N),Nrep)

for(n in 1:length(N)){ 
  for(k in 1:Nrep){
    show(paste(n,' - ',k))
    null_morans[n,k] = Moran(shuffleData(r),spatialWeights(N[n]))
  }
}

#save result
save(null_morans,morans,file="moran.Rdata",ascii=TRUE)


# plot results with error bars
library(ggplot2)
d = data.frame(meanCons,sdCons,lims)
ggplot(d, aes( y= meanCons, x= lims))+
  geom_line() +
  geom_point() +
  geom_errorbar(aes(ymin=meanCons-sdCons, ymax=meanCons+sdCons), width=.2) + 
  ggtitle("Lexical consistence = f(keyword limit)") +
  xlab("keyword limit") + ylab("mean consistence")






