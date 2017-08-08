
# build the network

source(paste0(Sys.getenv('CN_HOME'),'/Models/TransportationNetwork/NetworkAnalysis/network.R'))

# construct network
# speeds : RER 60km.h-1 -> 0.001 min.m-1 ; Transilien 100kmh ; Metro 30kmh ; Tram 20kmh
# communes : car, 50kmh ; fac : pied 5kmh
# RER
trgraph=addTransportationLayer('data/gis/gares.shp','data/gis/rer_lignes.shp',speed=0.001)
# Transilien
trgraph=addTransportationLayer('data/gis/gares.shp','data/gis/train_banlieue_lignes.shp',g = trgraph,speed=6e-04)
# Metro
trgraph=addTransportationLayer('data/gis/metro_stations.shp','data/gis/metro_lignes.shp',g = trgraph,speed=0.002)
# Tram
trgraph=addTransportationLayer('data/gis/TCSP_arrets.shp','data/gis/TCSP_lignes.shp',g = trgraph,speed=0.003)

# connexify
comps = components(trgraph);
cmax=which(sizes(comps)==max(sizes(comps)))
for(comp in unique(comps$membership)[-cmax]){if(sum(V(trgraph)$station[comps$membership==comp])>0){
  d = spDists(x=matrix(c(V(trgraph)$x[comps$membership==cmax],V(trgraph)$y[comps$membership==cmax]),nrow=length(which(comps$membership==cmax)),byrow = F),matrix(c(V(trgraph)$x[comps$membership==comp],V(trgraph)$y[comps$membership==comp]),nrow=length(which(comps$membership==comp)),byrow = F))
  minrow=which.min(apply(d,1,min));mincol=which.min(d[minrow,])
  trgraph=add_edges(trgraph,c(V(trgraph)$name[comps$membership==cmax][minrow],V(trgraph)$name[comps$membership==comp][mincol]),attr=list(speed=0.0012,length=d[minrow,mincol]))
}}
# keep largest comp
comps = components(trgraph);cmax = which(comps$csize==max(comps$csize))
trgraph = induced_subgraph(trgraph,which(comps$membership==cmax))

# arc express proche
tr_arcexpressproche=addTransportationLayer('data/gis/arcexpress_proche_gares.shp','data/gis/arcexpress_proche.shp',g = trgraph,speed=0.001)
# arc express loin
tr_arcexpressloin=addTransportationLayer('data/gis/arcexpress_eloigne_gares.shp','data/gis/arcexpress_eloigne.shp',g = trgraph,speed=0.001)
# reseau grand paris
tr_reseaugrandparis=addTransportationLayer('data/gis/reseaugrandparis_gares.shp','data/gis/reseaugrandparis.shp',g = trgraph,speed=0.001)
# grand paris express
tr_grandparisexpress=addTransportationLayer('data/gis/grandparisexpress_gares.shp','data/gis/grandparisexpress.shp',g = trgraph,speed=0.001)


# add communes and iris
tr_base = addAdministrativeLayer(trgraph,"data/gis/communes.shp",connect_speed = 0.0012,attributes=list("CP"="INSEE_COMM"))
tr_base = addAdministrativeLayer(tr_base,"data/gis/irisidf.shp",connect_speed = 0.0012,attributes=list("IRIS"="DCOMIRIS"))

tr_arcexpressproche = addAdministrativeLayer(tr_arcexpressproche,"data/gis/communes.shp",connect_speed = 0.0012,attributes=list("CP"="INSEE_COMM"))
tr_arcexpressproche = addAdministrativeLayer(tr_arcexpressproche,"data/gis/irisidf.shp",connect_speed = 0.0012,attributes=list("IRIS"="DCOMIRIS"))

tr_arcexpressloin = addAdministrativeLayer(tr_arcexpressloin,"data/gis/communes.shp",connect_speed = 0.0012,attributes=list("CP"="INSEE_COMM"))
tr_arcexpressloin = addAdministrativeLayer(tr_arcexpressloin,"data/gis/irisidf.shp",connect_speed = 0.0012,attributes=list("IRIS"="DCOMIRIS"))

tr_reseaugrandparis = addAdministrativeLayer(tr_reseaugrandparis,"data/gis/communes.shp",connect_speed = 0.0012,attributes=list("CP"="INSEE_COMM"))
tr_reseaugrandparis = addAdministrativeLayer(tr_reseaugrandparis,"data/gis/irisidf.shp",connect_speed = 0.0012,attributes=list("IRIS"="DCOMIRIS"))

tr_grandparisexpress = addAdministrativeLayer(tr_grandparisexpress,"data/gis/communes.shp",connect_speed = 0.0012,attributes=list("CP"="INSEE_COMM"))
tr_grandparisexpress = addAdministrativeLayer(tr_grandparisexpress,"data/gis/irisidf.shp",connect_speed = 0.0012,attributes=list("IRIS"="DCOMIRIS"))


#as.character(iris$DCOMIRIS)[!as.character(iris$DCOMIRIS)%in%V(tr_grandparisexpress)$IRIS]
#as.character(iris$DCOMIRIS)[!as.character(iris$DCOMIRIS)%in%V(tr_base)$IRIS]
# few iris missing -> connectivity issue ?


# filter on larger components
#comps = components(tr_base);cmin = which(comps$csize==max(comps$csize))
#tr_base = induced_subgraph(tr_base,which(comps$membership==cmin))
#comps = components(tr_arcexpressproche);cmin = which(comps$csize==max(comps$csize))
#tr_arcexpressproche = induced_subgraph(tr_arcexpressproche,which(comps$membership==cmin))
#comps = components(tr_arcexpressloin);cmin = which(comps$csize==max(comps$csize))
#tr_arcexpressloin = induced_subgraph(tr_arcexpressloin,which(comps$membership==cmin))
#comps = components(tr_reseaugrandparis);cmin = which(comps$csize==max(comps$csize))
#tr_reseaugrandparis = induced_subgraph(tr_reseaugrandparis,which(comps$membership==cmin))
#comps = components(tr_grandparisexpress);cmin = which(comps$csize==max(comps$csize))
#tr_grandparisexpress = induced_subgraph(tr_grandparisexpress,which(comps$membership==cmin))


# save the different graphs

save(tr_base,tr_arcexpressproche,tr_arcexpressloin,tr_reseaugrandparis,tr_grandparisexpress,file='data/networks2.RData')


## distance matrices
iris <- readOGR('data/gis','irisidf')
communes <- readOGR('data/gis','communes')

getDistMat<-function(g){
  fromids = c();fromnames=c();for(cp in iris$DCOMIRIS){fromids=append(fromids,which(V(g)$IRIS==cp));if(cp%in%V(g)$IRIS){fromnames=append(fromnames,cp)}}
  toids = c();tonames=c();for(cp in communes$INSEE_COMM){toids=append(toids,which(V(g)$CP==cp));if(cp%in%V(g)$CP){tonames=append(tonames,cp)}}
  res = distances(graph = g,v = fromids,to = toids,weights = E(g)$speed*E(g)$length)
  rownames(res)<-fromnames;colnames(res)<-tonames
  return(res)
}

dmat_base=getDistMat(tr_base)
dmat_arcexpressproche = getDistMat(tr_arcexpressproche)
dmat_arcexpressloin = getDistMat(tr_arcexpressloin)
dmat_reseaugrandparis = getDistMat(tr_reseaugrandparis)
dmat_grandparisexpress = getDistMat(tr_grandparisexpress)

# save
save(dmat_base,dmat_arcexpressproche,dmat_arcexpressloin,dmat_reseaugrandparis,dmat_grandparisexpress,file='data/dmats2.RData')








