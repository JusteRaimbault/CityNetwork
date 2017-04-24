
# build the network

source('network.R')


# construct network
# speeds : RER 60km.h-1 -> 0.001 min.m-1 ; Transilien 100kmh ; Metro 30kmh ; Tram 20kmh
# communes : car, 50kmh ; fac : pied 5kmh
# RER
trgraph=addTransportationLayer('data/gis/gares.shp','data/gis/rer_lignes.shp',speed=0.001)
# Transilien
trgraph=addTransportationLayer('data/gis/empty.shp','data/gis/train_banlieue_lignes.shp',g = trgraph,speed=6e-04)
# Metro
trgraph=addTransportationLayer('data/gis/metro_stations.shp','data/gis/metro_lignes.shp',g = trgraph,speed=0.002)
# Tram
trgraph=addTransportationLayer('data/gis/TCSP_arrets.shp','data/gis/TCSP_lignes.shp',g = trgraph,speed=0.003)


# arc express proche
tr_arcexpressproche=addTransportationLayer('data/gis/arcexpress_proche_gares.shp','data/gis/arcexpress_proche.shp',g = trgraph,speed=0.001)
# arc express loin
tr_arcexpressloin=addTransportationLayer('data/gis/arcexpress_eloigne_gares.shp','data/gis/arcexpress_eloigne.shp',g = trgraph,speed=0.001)
# reseau grand paris
tr_reseaugrandparis=addTransportationLayer('data/gis/reseaugrandparis_gares.shp','data/gis/reseaugrandparis.shp',g = trgraph,speed=0.001)
# grand paris express
tr_grandparisexpress=addTransportationLayer('data/gis/grandparisexpress_gares.shp','data/gis/grandparisexpress.shp',g = trgraph,speed=0.001)


# add communes and iris
tr_arcexpressproche = addAdministrativeLayer(tr_arcexpressproche,"data/gis/communes.shp",connect_speed = 0.0012,attributes=list("CP"="INSEE_COMM"))
tr_arcexpressproche = addAdministrativeLayer(tr_arcexpressproche,"data/gis/irisidf.shp",connect_speed = 0.0012,attributes=list("IRIS"="DCOMIRIS"))

tr_arcexpressloin = addAdministrativeLayer(tr_arcexpressloin,"data/gis/communes.shp",connect_speed = 0.0012,attributes=list("CP"="INSEE_COMM"))
tr_arcexpressloin = addAdministrativeLayer(tr_arcexpressloin,"data/gis/irisidf.shp",connect_speed = 0.0012,attributes=list("IRIS"="DCOMIRIS"))

tr_reseaugrandparis = addAdministrativeLayer(tr_reseaugrandparis,"data/gis/communes.shp",connect_speed = 0.0012,attributes=list("CP"="INSEE_COMM"))
tr_reseaugrandparis = addAdministrativeLayer(tr_reseaugrandparis,"data/gis/irisidf.shp",connect_speed = 0.0012,attributes=list("IRIS"="DCOMIRIS"))

tr_grandparisexpress = addAdministrativeLayer(tr_grandparisexpress,"data/gis/communes.shp",connect_speed = 0.0012,attributes=list("CP"="INSEE_COMM"))
tr_grandparisexpress = addAdministrativeLayer(tr_grandparisexpress,"data/gis/irisidf.shp",connect_speed = 0.0012,attributes=list("IRIS"="DCOMIRIS"))


# filter on larger components
comps = components(tr_arcexpressproche);cmin = which(comps$csize==max(comps$csize))
tr_arcexpressproche = induced_subgraph(tr_arcexpressproche,which(comps$membership==cmin))

comps = components(tr_arcexpressloin);cmin = which(comps$csize==max(comps$csize))
tr_arcexpressloin = induced_subgraph(tr_arcexpressloin,which(comps$membership==cmin))

comps = components(tr_reseaugrandparis);cmin = which(comps$csize==max(comps$csize))
tr_reseaugrandparis = induced_subgraph(tr_reseaugrandparis,which(comps$membership==cmin))

comps = components(tr_grandparisexpress);cmin = which(comps$csize==max(comps$csize))
tr_grandparisexpress = induced_subgraph(tr_grandparisexpress,which(comps$membership==cmin))



# save the different graphs

save(tr_arcexpressproche,tr_arcexpressloin,tr_reseaugrandparis,tr_grandparisexpress,file='data/networks.RData')







