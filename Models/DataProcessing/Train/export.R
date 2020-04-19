
setwd(paste0(Sys.getenv('CN_HOME'),'/Models/DataProcessing/Train'))

library(rgdal)


years = c(1831,1836,1841,1846,1851,1856,1861,1866,1872,1876,1881,
          1886,1891,1896,1901,1906,1911,1921,1926,1931,1936,
          1946,1954,1955,1962,1968,1975,1982,1990,1999)

#resolution = 1000
resolution = 10000

Ncities = 50

dir.create('graphs')



for(year in years){
  load(file=paste0('processed/',year,'_graph_res',resolution,'_cities',Ncities,'.RData'))
  # reproject in L93
  nodes = spTransform(SpatialPoints(data.frame(V(gcities)$x,V(gcities)$y),proj4string = crs("+proj=lcc +lat_1=44 +lat_2=49 +lat_0=46.5 +lon_0=3 +x_0=700000 +y_0=6600000 +ellps=GRS80 +units=m +no_defs")),
                    crs("+proj=lcc +lat_1=46.8 +lat_0=46.8 +lon_0=0 +k_0=0.99987742 +x_0=600000 +y_0=2200000 +a=6378249.2 +b=6356515 +towgs84=-168,-60,320,0,0,0,0 +pm=paris +units=m +no_defs")
  )
  # citydata$cities[,c("X","Y")]*100
  V(gcities)$x=nodes@coords[,1]/100;V(gcities)$y=nodes@coords[,2]/100
  
  gcities = induced_subgraph(gcities,V(gcities)[which((degree(gcities)>1)|(V(gcities)$city==T))])
  simpl = simplifyGraph(gcities)
  
  write.table(data.frame(V(simpl)$name,V(simpl)$x,V(simpl)$y),sep=",",col.names = F,row.names = F,file=paste0('graphs/',year,'_graph_res',resolution,'_cities',Ncities,'_nodes.csv'),quote = F)
  write.table(data.frame(head_of(simpl,es = E(simpl))$name,tail_of(simpl,es = E(simpl))$name,E(simpl)$speed),sep=",",col.names = F,row.names = F,file=paste0('graphs/',year,'_graph_res',resolution,'_cities',Ncities,'_edges.csv'),quote=F)
  
}
