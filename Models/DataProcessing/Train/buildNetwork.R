
setwd(paste0(Sys.getenv('CN_HOME'),'/Models/DataProcessing/Train'))

library(rgdal)

source(paste0(Sys.getenv('CN_HOME'),'/Models/TransportationNetwork/NetworkSimplification/nwSimplFunctions.R'))
source(paste0(Sys.getenv('CN_HOME'),'/Models/NetworkNecessity/InteractionGibrat/functions.R'))

# load raw data
troncons=readOGR(paste0(Sys.getenv('CN_HOME'),'/Data/Train/data'),'troncon')
stations=readOGR(paste0(Sys.getenv('CN_HOME'),'/Data/Train/data'),'stations')
stations$ouverture=as.numeric(as.character(stations$ouverture))
stations$fermeture=as.numeric(as.character(stations$fermeture))

years = c(1831,1836,1841,1846,1851,1856,1861,1866,1872,1881,
          1886,1891,1896,1901,1906,1911,1921,1926,1931,1936,
          1946,1954,1955,1962,1968,1975,1982,1990,1999)

resolution = 1000



# cities
Ncities = 50
citydata = loadData(Ncities)
# coordinates are LambertII, hectometrique.
# LII +proj=lcc +lat_1=46.8 +lat_0=46.8 +lon_0=0 +k_0=0.99987742 +x_0=600000 +y_0=2200000 +a=6378249.2 +b=6356515 +towgs84=-168,-60,320,0,0,0,0 +pm=paris +units=m +no_defs 
# data is Lambert93
# L93 +proj=lcc +lat_1=49 +lat_2=44 +lat_0=46.5 +lon_0=3 +x_0=700000 +y_0=6600000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 
cities = spTransform(SpatialPoints(citydata$cities[,c("X","Y")]*100,proj4string = crs("+proj=lcc +lat_1=46.8 +lat_0=46.8 +lon_0=0 +k_0=0.99987742 +x_0=600000 +y_0=2200000 +a=6378249.2 +b=6356515 +towgs84=-168,-60,320,0,0,0,0 +pm=paris +units=m +no_defs")),
            crs("+proj=lcc +lat_1=44 +lat_2=49 +lat_0=46.5 +lon_0=3 +x_0=700000 +y_0=6600000 +ellps=GRS80 +units=m +no_defs")
            )

speedVar<-function(year,spdf){
  vars=names(spdf)[grep('V_moy',names(spdf),fixed=T)]
  tdif=abs(as.numeric(substring(vars,7,11))-year)
  return(vars[tdif==min(tdif)][1])
}

for(year in years){
  show(paste0(year," : ",length(which(troncons$Ouverture<=year&troncons$Fermeture>year))))
  currentnw = troncons[troncons$Ouverture<=year&troncons$Fermeture>year,]
  currentnw@data[currentnw@data[,speedVar(year,currentnw)]==0,speedVar(year,currentnw)]=50
  currentnw$speed = 1/(currentnw@data[,speedVar(year,currentnw)]*1000/60) # speed in min.m^1
  gfull=graphFromSpdf(currentnw,resolution=resolution)
  #png(filename = paste0(Sys.getenv('CN_HOME'),'/Models/DataProcessing/Train/networks/',year,'full.png'),width=30,height=30,units='cm',res=600)
  #plot(gfull,vertex.size=0.1,vertex.label=NA,edge.color='black',edge.width=1/(E(gfull)$speed*1000),rescale=T)
  #dev.off()
  
  gfull = connexify(gfull,pace=0.0012)
  
  # add stations
  currentstations = stations[stations$ouverture<=year&stations$fermeture>year,]
  currentstations$insee = paste0(as.character(currentstations$insee_comm),'00')
  currentstations=currentstations[!duplicated(currentstations$insee),] # keep one station per commun, large enough
  gstations = add_vertices(gfull,length(currentstations),attr = list(name=currentstations$insee,x=currentstations@coords[,1],y=currentstations@coords[,2]))
  d=spDists(currentstations@coords,matrix(c(V(gfull)$x,V(gfull)$y),nrow=vcount(gfull),byrow = F))
  edges = c(t(matrix(c(currentstations$insee,apply(d,1,function(r){V(gfull)$name[which.min(r)]})),nrow=nrow(d),byrow = F)))
  gstations=add_edges(gstations,edges,attr=list(speed=rep(0.0012,nrow(d)),length=apply(d,1,min)))
  rm(d);gc()
  
  # add cities
  V(gstations)$station = nchar(V(gstations)$name)==7
  d=spDists(cities@coords,matrix(c(V(gstations)$x[V(gstations)$station==T],V(gstations)$y[V(gstations)$station==T]),nrow=length(which(V(gstations)$station)),byrow = F))
  edges = c(t(matrix(c(citydata$cities$NCCU,apply(d,1,function(r){V(gstations)$name[V(gstations)$station==T][which.min(r)]})),nrow=nrow(d),byrow = F)))
  gcities = add_vertices(gstations,length(cities),attr = list(name=citydata$cities$NCCU,x=cities@coords[,1],y=cities@coords[,2]))
  gcities=add_edges(gcities,edges,attr=list(speed=rep(0.0012,nrow(d)),length=apply(d,1,min)))
  V(gcities)$city=is.na(as.numeric(V(gcities)$name))
  distmat = distances(gcities,which(V(gcities)$city),which(V(gcities)$city),weights=E(gcities)$length*E(gcities)$speed)
  
  # save all
  save(distmat,file=paste0('processed/',year,'_dmat_res',resolution,'_cities',Ncities,'.RData'))
  save(gcities,file=paste0('processed/',year,'_graph_res',resolution,'_cities',Ncities,'.RData'))
  write.table(distmat,col.names = F,row.names = F,file=paste0('processed/',year,'_dmat_res',resolution,'_cities',Ncities,'.csv'))
  
  # simplify -> can do without.
  #gsimpl = simplifyGraph(gfull)
  #plot(gsimpl,vertex.size=0.5,vertex.label=NA,vertex.color='black',edge.color='black',edge.width=1/(E(gfull)$speed*1000),rescale=T)
}

