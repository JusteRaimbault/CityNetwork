
# nw simplification functions

pgsqlcon = dbConnect(dbDriver("PostgreSQL"), dbname="osm",user="Juste",host="localhost" )


#' Get road linestrings (SPatialLines) within given extent
#'
#' @param latmin,lonmin,latmax,lonmax bbox
#' @param tags list of tag values (for key highway)
#'
linesWithinExtent<-function(latmin,lonmin,latmax,lonmax,tags){
  q = paste0(
    "SELECT ST_AsText(linestring) AS geom FROM ways",
    " WHERE ST_Contains(ST_MakeEnvelope(",latmin,",",lonmin,",",latmax,",",lonmax,",4326),","linestring)")
  if(length(tags)>0){
    q=paste0(q," AND (")
    for(i in 1:(length(tags)-1)){q=paste0(q,"tags::hstore->'highway'='",tags[i],"' OR ")}
    q=paste0(q,"tags::hstore->'highway'='",tags[length(tags)],"')")
  }
  q=paste0(q,";")
  query = dbSendQuery(pgsqlcon,q)
  data = fetch(query,n=-1)
  geoms = data$geom
  roads=list()
  for(i in 1:length(geoms)){
    r=readWKT(geoms[i])@lines[[1]];r@ID=as.character(i)
    roads[[i]]=r
  } 
  return(roads)
}

#' Get graph edges from Lines list and reference raster
#'
#'   iterate on roads to create an "edgelist" of connexions between raster cells
graphEdgesFromLines<-function(roads,baseraster){
  edgelist=list()
  for(i in 1:length(roads)){
    if(i%%1000==0){show(i)}
    coords = roads[[i]]@Lines[[1]]@coords
    # assume a connection at each vertex, ignores 'tunnel effect' -> ok at these scales
    conn = unique(cellFromXY(baseraster,coords))
    if(length(conn)>1){
      for(j in 1:(length(conn)-1)){
        edgelist=append(edgelist,list(conn[j:(j+1)]))
      }
    }
  }
  return(edgelist)
}


#' Graph simplification
#'
#'
simplifyGraph<-function(g){
  degrees=degree(g)
  remvertices = V(g)[which(degrees==2)]
  edgestoadd=c();vtodelete=V(g)[0]
  while(length(remvertices)>0){
    v=remvertices[1]
    n=neighbors(g,v);prevo=v;prevd=v
    o=n[1];d=n[2];p=c(v,o,d)
    while(max(degree(g,v=o))==2){
      no=neighbors(g,o);tmpo=o;o=no[which(no!=prevo)];prevo=tmpo;p=append(p,o)
      # TODO link o - prevo added to cumulate weight
    }
    while(max(degree(g,v=d))==2){nd=neighbors(g,d);tmpd=d;d=nd[which(nd!=prevd)];prevd=tmpd;p=append(p,d)}
    # delete path vertices and add edge
    remvertices=difference(remvertices,p[which(p!=o&p!=d)])
    edgestoadd=append(edgestoadd,c(o$name,d$name))
    vtodelete=append(vtodelete,p[which(p!=o&p!=d)])
    show(length(remvertices))
  }
  return(delete_vertices(g,vtodelete)%>% add_edges(edgestoadd))
}



