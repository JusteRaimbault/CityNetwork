
# Map accessibility changes in PRD

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/CaseStudies/PRD'))

library(rgdal)
library(raster)
library(Matrix)

source(paste0(Sys.getenv('CN_HOME'),'/Models/TransportationNetwork/NetworkAnalysis/network.R'))
source(paste0(Sys.getenv('CN_HOME'),'/Models/SpatioTempCausality/functions.R'))

resdir = paste0(Sys.getenv('CN_HOME'),'/Results/CaseStudies/PRD/')

trgraph=addTransportationLayer(link_layer = 'data/networkBaidu.shp',speed=6e-04,snap=10)
#plot(trgraph,vertex.size=rep(0,vcount(trgraph)),vertex.label=rep(NA,vcount(trgraph)))
# summary(c(distances(trgraph,weights=E(trgraph)$speed*E(trgraph)$length)))

trbridgeraw=addTransportationLayer(link_layer = 'data/networkPlannedBaidu.shp',g = trgraph,speed=6e-04,snap=10)

# read the population raster
pop = raster(x = 'data/pop2010_wgs84_georef.asc')
crs(pop)<-CRS('+proj=longlat +datum=WGS84 +no_defs')
popdata =  data.frame(cbind(xyFromCell(pop,1:ncell(pop)),pop=getValuesBlock(pop,nrows=nrow(pop),ncols=ncol(pop))))

poppoints = SpatialPointsDataFrame(popdata[popdata$pop>0,c("x","y")],popdata[popdata$pop>0,])
poppoints$id = as.character(1:length(poppoints))

trbase = addAdministrativeLayer(trgraph,poppoints,connect_speed = 1e-3,attributes=list("pop"="pop","id"="id"))
trbridge = addAdministrativeLayer(trbridgeraw,poppoints,connect_speed = 1e-3,attributes=list("pop"="pop","id"="id"))

#E(trbase)$speed[E(trbase)$speed==0.1]=1e-3
#E(trbridge)$speed[E(trbridge)$speed==0.1]=1e-3

dmat_base = distances(graph = trbase,v = which(V(trbase)$station==0),to = which(V(trbase)$station==1),weights = E(trbase)$speed*E(trbase)$length)
rownames(dmat_base)<-V(trbase)$id[V(trbase)$station==0]

dmat_bridge = distances(graph = trbridge,v = which(V(trbridge)$station==0),to = which(V(trbridge)$station==1),weights = E(trbridge)$speed*E(trbridge)$length)
rownames(dmat_bridge)<-V(trbridge)$id[V(trbridge)$station==0]

#save(trgraph,trbase,trbridgeraw,trbridge,file='processed/graphs.RData')
load('processed/graphs.RData')


# compute node populations
npop = colSums(Diagonal(x = poppoints$pop)%*%Matrix(t(apply(dmat_base,1,function(r){as.numeric(r==min(r))}))))
# check
# sum(nodespop)==sum(poppoints$pop)

npopb = colSums(Diagonal(x = poppoints$pop)%*%Matrix(t(apply(dmat_bridge,1,function(r){as.numeric(r==min(r))}))))


decay = 2
year=2010

nodespop = data.frame(id=V(trgraph)$name,year=rep(year,vcount(trgraph)),var=npop)
nodespopb = data.frame(id=V(trbridgeraw)$name,year=rep(year,vcount(trbridgeraw)),var=npopb)

accesstime_withoutbridge = computeAccess(data.frame(id=rownames(dmat_base),var=rep(1,nrow(dmat_base)),year=rep(year,nrow(dmat_base))),data.frame(id=colnames(dmat_base),var=rep(1,ncol(dmat_base)),year=rep(year,ncol(dmat_base))),exp(-dmat_base/decay))
accesstime_withbridge = computeAccess(data.frame(id=rownames(dmat_bridge),var=rep(1,nrow(dmat_bridge)),year=rep(year,nrow(dmat_bridge))),data.frame(id=colnames(dmat_bridge),var=rep(1,ncol(dmat_bridge)),year=rep(year,ncol(dmat_bridge))),exp(-dmat_bridge/decay))
accesstimediff = accesstime_withoutbridge;accesstimediff$var = accesstime_withoutbridge$var - accesstime_withbridge$var
# summary(accesstimediff$var)

#accessp_withoutbridge = computeAccess(data.frame(id=rownames(dmat_base),var=rep(1,nrow(dmat_base)),year=rep(year,nrow(dmat_base))),nodespop,exp(-dmat_base/decay))
#accessp_withbridge = computeAccess(data.frame(id=rownames(dmat_bridge),var=rep(1,nrow(dmat_bridge)),year=rep(year,nrow(dmat_bridge))),nodespopb,exp(-dmat_bridge/decay))

#accesspediff = accessp_withbridge;accesspediff$var = accessp_withoutbridge$var - accessp_withbridge$var
#accesspediff$var = (accesspediff$var - mean(accesspediff$var))/sd(accesspediff$var)

#pol <- rasterToPolygons(pop, fun=function(x){x>0})
Polygons()
xr=xres(pop);yr=yres(pop)
sppol = SpatialPolygons(
    apply(poppoints@data,1,function(r){
      r = as.numeric(r)
      Polygons(list(Polygon(matrix(c(r[1]-xr/2,r[2]+yr/2,r[1]+xr/2,r[2]+yr/2,r[1]+xr/2,r[2]-yr/2,r[1]-xr/2,r[2]-yr/2,r[1]-xr/2,r[2]+yr/2),ncol=2,byrow = T))),ID = as.character(r[4]))
      })
    ,proj4string = crs(pop))
spdat=poppoints@data;rownames(spdat)<-sapply(sppol@polygons,function(p){p@ID})
spdf=SpatialPolygonsDataFrame(sppol,data = spdat)

map(data=accesstimediff,layer=spdf,spdfid="id",dfid="id",variable="var",
    filename=paste0(resdir,'accesstimediff_prd.png'),title=paste0("Gains d'accessibilite"),legendtitle = "Gain\nnormalise",extent=readOGR('data','networkBaidu'),
    nclass=8,
    width=15,height=12,palette='div',lwd=0.01,
    additionalLinelayers=list(list(readOGR('data','networkBaidu'),'blue',readOGR('data','networkPlannedBaidu'),'purple')),
    withScale=0
)





