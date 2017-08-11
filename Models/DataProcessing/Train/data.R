
library(rgdal)
library(dplyr)

rail <- readOGR(paste0(Sys.getenv('CN_HOME'),'/Data/Train/data'),'troncon')

par(mfrow=c(2,5))
for(year in seq(from=1830,to=2010,by=20)){
  troncons = rail@data$Ouverture<=year&rail@data$Fermeture>year
  plot(SpatialLines(rail@lines[troncons]),main=year)
}