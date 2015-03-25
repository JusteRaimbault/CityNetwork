
# Morphological analysis of population densities

# using package spatstat
library(spatstat)
#beginner
#vignette('getstart')

#needs raster also
library(raster)
library(rgdal)

# create data structures
# load raw raster
raw <- raster("/Users/Juste/Documents/ComplexSystems/CityNetwork/Data/PopulationDensity/raw/uk-lr.tif")
m = as.matrix(raw)
m[is.na(m)] <- 0

hist(c(m),breaks=100)

#composition of raster ?
threshold = 100
sum(m>threshold)/length(m)

binmat<- m>threshold
sum(binmat)/length(m)

plot(im(binmat))

w <- owin(mask=binmat)
plot(w)


# morpho treatment

radius=3
rep=15
o=w
for(i in 1:rep){
  show(paste("it",i))
  o <- closing(o,radius)
  o <- opening(o,radius)
}

plot(o)

#save result to view externally
# pb ?
writeRaster(raster(as.im(o)),paste0("/Users/Juste/Documents/ComplexSystems/CityNetwork/Data/PopulationDensity/processed/uk_closed_opened",radius,"_rep",rep,".tif"),"GTiff")




####### Analysis of area distribution #######


m = as.matrix(o)

# quick function to get connex areas

# one pass algo, marking pop pixels with number of area

# auxiliary function to explore a connex area
#  ¡¡ not recursive, explose very quickly the stack !!
#  -> write iterative equivalent
# propagate <- function(m,indices,i,j,n){
#   indices[i,j]=n
#   if(i>1){if(indices[i-1,j]==0&&m[i-1,j]==TRUE){indices = propagate(m,indices,i-1,j,n)}}
#   if(i<nrow(m)){if(indices[i+1,j]==0&&m[i+1,j]==TRUE){indices = propagate(m,indices,i+1,j,n)}}
#   if(j>1){if(indices[i,j-1]==0&&m[i,j-1]==TRUE){indices = propagate(m,indices,i,j-1,n)}}
#   if(j<ncol(m)){if(indices[i,j+1]==0&&m[i,j+1]==TRUE){indices = propagate(m,indices,i,j+1,n)}}
#   return(indices)
# }

library(rlist)
# iterative version
propagate <- function(m,indices,ii,jj,n){
  pile = list(c(ii,jj))
  while(length(pile)>0){
    # unstack first
    coords = list.take(pile,1)[[1]] ; pile = list.remove(pile,1);
    i=coords[1];j=coords[2];
    # update indices
    indices[i,j]=n
    #stack neighbors of conditions are met
    if(i>1){if(indices[i-1,j]==0&&m[i-1,j]==TRUE){pile = list.prepend(pile,c(i-1,j))}}
    if(i<nrow(m)){if(indices[i+1,j]==0&&m[i+1,j]==TRUE){pile = list.prepend(pile,c(i+1,j))}}
    if(j>1){if(indices[i,j-1]==0&&m[i,j-1]==TRUE){pile = list.prepend(pile,c(i,j-1))}}
    if(j<ncol(m)){if(indices[i,j+1]==0&&m[i,j+1]==TRUE){pile = list.prepend(pile,c(i,j+1))}}
  }  
  return(indices)
}

connexAreas <- function(m){
  indices <- matrix(data=rep(0,nrow(m)*ncol(m)),nrow=nrow(m),ncol=ncol(m))
  maxArea = 0
  
  for(i in 1:nrow(m)){
    for(j in 1:ncol(m)){
      # if colored but not marked, mark recursively
      #   -- necessarily a new area
      if(m[i,j]==TRUE&&indices[i,j]==0){
        maxArea = maxArea + 1
        show(paste("Prop",i,j," - area ",maxArea))
        indices <- propagate(m,indices,i,j,maxArea)
      }
    }
  }
  
  
  # use indices to create list of coordinates
  
  areas = list()
  for(a in 1:maxArea){
    areas=list.append(areas,which(indices==a))
  }
  
  return(areas)
}


areas = connexAreas(m)

sizes =  unlist(list.apply(areas,length))

plot(sort(log(sizes),decreasing=TRUE))
plot(log(sizes),breaks=100)

h = hist(log(sizes),breaks=100,plot=FALSE)
plot(h$mids,log(h$counts))


## Rq : only binary selection, then look at size of agglomeration
#  -> only morphological size, not effective size in population
#   do it with densities ? : pb with morpho treatment ?!







