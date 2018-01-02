
# Map accessibility changes in PRD

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/CaseStudies/PRD'))

library(rgdal)
library(raster)
library(Matrix)

source(paste0(Sys.getenv('CN_HOME'),'/Models/TransportationNetwork/NetworkAnalysis/network.R'))
source(paste0(Sys.getenv('CN_HOME'),'/Models/SpatioTempCausality/functions.R'))

resdir = paste0(Sys.getenv('CN_HOME'),'/Results/CaseStudies/PRD/')

trgraph=addTransportationLayer(link_layer = 'data/networkBaidu.shp',speed=6e-04,snap=10)
trgraph=addTransportationLayer(stations_layer = 'data/empty.shp',link_layer = 'data/networkPlannedBaidu.shp',g = trgraph,speed=6e-04,snap=10)
V(trgraph)$new = 1 - V(trgraph)$station 

#plot(trgraph,vertex.size=rep(0,vcount(trgraph)),vertex.label=rep(NA,vcount(trgraph)))
# summary(c(distances(trgraph,weights=E(trgraph)$speed*E(trgraph)$length)))

# read the population raster
pop = raster(x = 'data/pop2010_wgs84_georef.asc')
crs(pop)<-CRS('+proj=longlat +datum=WGS84 +no_defs')
popdata =  data.frame(cbind(xyFromCell(pop,1:ncell(pop)),pop=getValuesBlock(pop,nrows=nrow(pop),ncols=ncol(pop))))

poppoints = SpatialPointsDataFrame(popdata[popdata$pop>0,c("x","y")],popdata[popdata$pop>0,])
poppoints$id = as.character(1:length(poppoints))

trbridge = addAdministrativeLayer(trgraph,poppoints,connect_speed = 1e-3,attributes=list("pop"="pop","id"="id"))
trbridge = addAdministrativeLayer(trbridge,'data/hongkong.shp',connect_speed = 1e-3,attributes=list("pop"="POP"))
V(trbridge)$station[as.numeric(V(trbridge)$pop)>1000000]=1
V(trbridge)$id[V(trbridge)$station==1]=paste0("s",1:length(which(V(trbridge)$station==1)))
trbase = induced_subgraph(trbridge,V(trbridge)[!is.na(V(trbridge)$id)])


#save(trgraph,trbase,trbridge,file='processed/graphs.RData')
load('processed/graphs.RData')

dmat_base = distances(graph = trbase,v = which(V(trbase)$station==0),to = which(V(trbase)$station==1),weights = E(trbase)$speed*E(trbase)$length)
rownames(dmat_base)<-V(trbase)$id[V(trbase)$station==0]
colnames(dmat_base)<-V(trbase)$id[V(trbase)$station==1]

dmat_bridge = distances(graph = trbridge,v = which(V(trbridge)$station==0&is.na(V(trbridge)$new)),to = which(V(trbridge)$station==1),weights = E(trbridge)$speed*E(trbridge)$length)
rownames(dmat_bridge)<-V(trbridge)$id[V(trbridge)$station==0&is.na(V(trbridge)$new)]
colnames(dmat_bridge)<-V(trbridge)$id[V(trbridge)$station==1]

save(dmat_base,dmat_bridge,file='processed/dmats.RData')

# compute node populations
npop = colSums(Diagonal(x = poppoints$pop)%*%Matrix(t(apply(dmat_base,1,function(r){as.numeric(r==min(r))}))))

decay = 3
year=2010

V(trbase)$pop[is.na(V(trbase)$pop)]=0

nodespop = data.frame(id=c(V(trbase)$id[V(trbase)$station==1],V(trbase)$id[as.numeric(V(trbase)$pop)>1000000]),year=rep(year,length(which(V(trbase)$station==1))+1),var=c(npop,V(trbase)$pop[as.numeric(V(trbase)$pop)>1000000]))
nodespop$var = as.numeric(as.character(nodespop$var))

nodespop_nohk = data.frame(id=V(trbase)$id[V(trbase)$station==1],year=rep(year,length(which(V(trbase)$station==1))),var=npop)
nodespop_nohk$var = as.numeric(as.character(nodespop_nohk$var))


accesstime_withoutbridge = computeAccess(data.frame(id=rownames(dmat_base),var=rep(1,nrow(dmat_base)),year=rep(year,nrow(dmat_base))),data.frame(id=colnames(dmat_base),var=rep(1,ncol(dmat_base)),year=rep(year,ncol(dmat_base))),exp(-dmat_base/decay))
accesstime_withbridge = computeAccess(data.frame(id=rownames(dmat_bridge),var=rep(1,nrow(dmat_bridge)),year=rep(year,nrow(dmat_bridge))),data.frame(id=colnames(dmat_bridge),var=rep(1,ncol(dmat_bridge)),year=rep(year,ncol(dmat_bridge))),exp(-dmat_bridge/decay))
accesstimediff = accesstime_withoutbridge;accesstimediff$var = accesstime_withoutbridge$var - accesstime_withbridge$var
# summary(accesstimediff$var)

accessp_withoutbridge = computeAccess(data.frame(id=rownames(dmat_base),var=rep(1,nrow(dmat_base)),year=rep(year,nrow(dmat_base))),nodespop,exp(-dmat_base/decay))
accessp_withbridge = computeAccess(data.frame(id=rownames(dmat_bridge),var=rep(1,nrow(dmat_bridge)),year=rep(year,nrow(dmat_bridge))),nodespop,exp(-dmat_bridge/decay))
accesspdiff = accessp_withbridge;accesspdiff$var = accessp_withbridge$var - accessp_withoutbridge$var
accesspdiff$var = (accesspdiff$var - mean(accesspdiff$var))/sd(accesspdiff$var)


summary(accesspdiff)

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

#accesstimediff$var[accesstimediff$var>0]=NA

map(data=accesstimediff,layer=spdf,spdfid="id",dfid="id",variable="var",
    filename=paste0(resdir,'accesstimediff_prd.png'),title=paste0("Gains d'accessibilite"),
    legendtitle = "Gain\nnormalise",extent=readOGR('data','networkBaidu'),
    nclass=4,
    width=15,height=15,palette='div',lwd=0.01,
    additionalLinelayers=list(
      list(readOGR('data','networkBaidu'),'blue'),
      list(readOGR('data','networkPlannedBaidu'),'purple')#,
      #list(readOGR('data','counties'),'black')
    ),
    withScale=NULL,
    legendPosition = "bottomright"
)

map(data=accesspdiff,layer=spdf,spdfid="id",dfid="id",variable="var",
    filename=paste0(resdir,'accesspdiff_prd.png'),title=paste0("Gains d'accessibilite"),
    legendtitle = "Gain\nnormalise",extent=readOGR('data','networkBaidu'),
    nclass=4,breaks = c(min(accesspdiff$var),quantile(accesspdiff$var[accesspdiff$var>0],c(0,0.33,0.66,1.0))),
    width=15,height=15,palette='div',lwd=0.01,
    additionalLinelayers=list(
      list(readOGR('data','networkBaidu'),'blue'),
      list(readOGR('data','networkPlannedBaidu'),'purple')#,
      #list(readOGR('data','counties'),'black')
    ),
    additionalLabelLayers=list(list(readOGR('data','cities'),'black','Nom')),
    withScale=NULL,
    legendPosition = "bottomright"
)

accessp_withbridge$var = accessp_withbridge$var / sum(nodespop$var)

map(data=accessp_withbridge,layer=spdf,spdfid="id",dfid="id",variable="var",
    filename=paste0(resdir,'accessp_withbridge_prd.png'),title=paste0("Accessibilite (avec pont)"),
    legendtitle = "Accessibilite",extent=readOGR('data','networkBaidu'),
    nclass=8,
    width=15,height=15,palette='div',lwd=0.01,
    additionalLinelayers=list(
      list(readOGR('data','networkBaidu'),'blue'),
      list(readOGR('data','networkPlannedBaidu'),'purple')#,
      #list(readOGR('data','counties'),'black')
    ),
    additionalLabelLayers=list(list(readOGR('data','cities'),'black','Nom')),
    withScale=NULL,
    legendPosition = "bottomright"
)

accessp_withoutbridge$var = accessp_withoutbridge$var / sum(nodespop$var)

map(data=accessp_withoutbridge,layer=spdf,spdfid="id",dfid="id",variable="var",
    filename=paste0(resdir,'accessp_withoutbridge_prd.png'),title=paste0("Accessibilite (sans pont)"),
    legendtitle = "Accessibilite",extent=readOGR('data','networkBaidu'),
    nclass=8,
    width=15,height=15,palette='div',lwd=0.01,
    additionalLinelayers=list(
      list(readOGR('data','networkBaidu'),'blue')
      #list(readOGR('data','counties'),'black')
    ),
    additionalLabelLayers=list(list(readOGR('data','cities'),'black','Nom')),
    withScale=NULL,
    legendPosition = "bottomright"
)


# same without hk

accessp_withoutbridge_nohk = computeAccess(data.frame(id=rownames(dmat_base),var=rep(1,nrow(dmat_base)),year=rep(year,nrow(dmat_base))),nodespop_nohk,exp(-dmat_base/decay))
accessp_withbridge_nohk = computeAccess(data.frame(id=rownames(dmat_bridge),var=rep(1,nrow(dmat_bridge)),year=rep(year,nrow(dmat_bridge))),nodespop_nohk,exp(-dmat_bridge/decay))
accesspdiff_nohk = accessp_withbridge_nohk;accesspdiff_nohk$var = accessp_withbridge_nohk$var - accessp_withoutbridge_nohk$var
accesspdiff_nohk$var = (accesspdiff_nohk$var - mean(accesspdiff_nohk$var))/sd(accesspdiff_nohk$var)



map(data=accesspdiff_nohk,layer=spdf,spdfid="id",dfid="id",variable="var",
    filename=paste0(resdir,'accesspdiff_prd_nohk.png'),title=paste0("Gains d'accessibilite"),
    legendtitle = "Gain\nnormalise",extent=readOGR('data','networkBaidu'),
    nclass=4,breaks = c(min(accesspdiff$var),quantile(accesspdiff$var[accesspdiff$var>0],c(0,0.33,0.66,1.0))),
    width=15,height=15,palette='div',lwd=0.01,
    additionalLinelayers=list(
      list(readOGR('data','networkBaidu'),'blue'),
      list(readOGR('data','networkPlannedBaidu'),'purple')#,
      #list(readOGR('data','counties'),'black')
    ),
    additionalLabelLayers=list(list(readOGR('data','cities'),'black','Nom')),
    withScale=NULL,
    legendPosition = "bottomright"
)

accessp_withbridge_nohk$var = accessp_withbridge_nohk$var / sum(nodespop_nohk$var)

map(data=accessp_withbridge_nohk,layer=spdf,spdfid="id",dfid="id",variable="var",
    filename=paste0(resdir,'accessp_withbridge_prd_nohk.png'),title=paste0("Accessibilite (avec pont)"),
    legendtitle = "Accessibilite",extent=readOGR('data','networkBaidu'),
    nclass=8,
    width=15,height=15,palette='div',lwd=0.01,
    additionalLinelayers=list(
      list(readOGR('data','networkBaidu'),'blue'),
      list(readOGR('data','networkPlannedBaidu'),'purple')#,
      #list(readOGR('data','counties'),'black')
    ),
    additionalLabelLayers=list(list(readOGR('data','cities'),'black','Nom')),
    withScale=NULL,
    legendPosition = "bottomright"
)

accessp_withoutbridge_nohk$var = accessp_withoutbridge_nohk$var / sum(nodespop$var)

map(data=accessp_withoutbridge_nohk,layer=spdf,spdfid="id",dfid="id",variable="var",
    filename=paste0(resdir,'accessp_withoutbridge_prd_nohk.png'),title=paste0("Accessibilite (sans pont)"),
    legendtitle = "Accessibilite",extent=readOGR('data','networkBaidu'),
    nclass=8,
    width=15,height=15,palette='div',lwd=0.01,
    additionalLinelayers=list(
      list(readOGR('data','networkBaidu'),'blue')
      #list(readOGR('data','counties'),'black')
    ),
    additionalLabelLayers=list(list(readOGR('data','cities'),'black','Nom')),
    withScale=NULL,
    legendPosition = "bottomright"
)



