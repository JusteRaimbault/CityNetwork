
## road network simplification : test

#library(osmar)
#osmosis <- osmsource_osmosis(file='Data/OSM/andorra-latest.osm')
#area <- center_bbox(1.55,42.55,30000,30000)
#data <- get_osm(x=area,source = osmosis)
# 6.10 ; 49.75

## Do not use osm directly, not efficient

latmin=5.5;latmax=6.5;lonmin=49.0;lonmax=51

library(RPostgreSQL)
library(rgeos)
library(rgdal)
library(raster)
library(igraph)

pgsqlcon = dbConnect(dbDriver("PostgreSQL"), dbname="osm",user="Juste",host="localhost" )


linesWithinCell<-function(latmin,lonmin,latmax,lonmax){
  query = dbSendQuery(pgsqlcon,paste0(
     "SELECT ST_AsText(linestring) AS geom FROM ways",
     " WHERE ST_Contains(ST_MakeEnvelope(",latmin,",",lonmin,",",latmax,",",lonmax,",4326),","linestring)",
     " AND (tags::hstore->'highway'='motorway' OR tags::hstore->'highway'='trunk' OR tags::hstore->'highway'='primary' OR tags::hstore->'highway'='secondary')",# OR tags::hstore->'highway'='tertiary')",
     ";")
  )

  data = fetch(query,n=-1)

  geoms = data$geom

  roads=list()
  for(i in 1:length(geoms)){
    r=readWKT(geoms[i])@lines[[1]];r@ID=as.character(i)
    roads[[i]]=r
  }

  return(roads)
}



#plot(splines)

wgs84='+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'

# nodes density -> sp aggregation
#rasterize(splines,raster(extent(splines),nrow=100,ncol=100),fun='count')
# or get raster from density data -> will be directly consistent.
#densraster <- raster(paste0(Sys.getenv("CN_HOME"),"/Data/PopulationDensity/raw/popu01clcv5.tif"))
#projdens <- projectRaster(from=densraster,crs=wgs84)
#extent(splines)

roads = linesWithinCell(latmin,lonmin,latmax,lonmax)
splines = SpatialLines(LinesList = roads)

base = raster(extent(splines),nrow=500,ncol=500)
#resx=res(base)[1];resy=res(base)[2]
#xyFromCell(base,50)

#cellnum=50
#plot(SpatialLines(LinesList = linesWithinCell(
#  xyFromCell(base,cellnum)[1]-resx,xyFromCell(base,cellnum)[2]-resy,xyFromCell(base,cellnum)[1]+resx,xyFromCell(base,cellnum)[2]+resy)))




# iterate on roads to create an "edgelist" of connexions between raster cells

edgelist=list()
for(i in 1:length(roads)){
  if(i%%1000==0){show(i)}
  coords = roads[[i]]@Lines[[1]]@coords
  # assume start->end : 'tunnel effect'
  #cellFromLine(base,lns=SpatialLines(roads[[i]]))
  conn = unique(cellFromXY(base,coords))
  if(length(conn)>1){
    for(j in 1:(length(conn)-1)){
      edgelist=append(edgelist,list(conn[j:(j+1)]))
    }
  }
}

#nodes = unique(unlist(edgelist))
#xyFromCell(base,nodes)

edgesmat=matrix(data=as.character(unlist(edgelist)),ncol=2,byrow=TRUE)

g = graph_from_edgelist(edgesmat,directed=FALSE)
coords = xyFromCell(base,as.numeric(V(g)$name))
V(g)$x=coords[,1];V(g)$y=coords[,2]
#plot(g,layout=coords,vertex.size=0,vertex.label=NA,edge.loop.angle=NA)

#summary(degree(g))
#V(g)[which(degree(g)==max(degree(g)))]
#centralization.betweenness(g)
#diameter(g)

simplifyGraph<-function(g){
  #show("simpli")
  res = g
  degrees=degree(res)
  while(length(which(degrees==2))>0){
    v=V(res)[which(degrees==2)[1]]
    n=neighbors(res,v);prevo=v;prevd=v
    o=n[1];d=n[2];p=c(v,o,d)
    while(max(degree(res,v=o))==2){
      no=neighbors(res,o);tmpo=o;o=no[which(no!=prevo)];prevo=tmpo;p=append(p,o)
      # TODO link o - prevo added to cumulate weight
    }
    while(max(degree(res,v=d))==2){nd=neighbors(res,d);tmpd=d;d=nd[which(nd!=prevd)];prevd=tmpd;p=append(p,d)}
    # delete path vertices and add edge
    res<-delete_vertices(res,p[which(p!=o&p!=d)])
    res<-add_edges(res,c(o$name,d$name))
    degrees=degree(res)
    #gc()
    show(length(which(degrees==2)))
  }
  show(res)
  return(res)
}

sg <- simplifyGraph(g)

# can test indicators computation on simplified graph
centralization_betweeness(sg)
diameter(sg)

# operational : put raster cell in db -> need unique id for all Europe : reproject in WGS84
#  : sqlitedb ?










