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


