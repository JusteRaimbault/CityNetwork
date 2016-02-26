
# nw simplification functions

pgsqlcon = dbConnect(dbDriver("PostgreSQL"), dbname="osm",user="Juste",host="localhost" )


#' Get road linestrings (SPatialLines) within given extent
#'
#' @param latmin,lonmin,latmax,lonmax bbox
#' @param tags list of tag values (for key highway)
#'
linesWithinExtent<-function(latmin,lonmin,latmax,lonmax,tags){
  q = paste0(
    "SELECT ST_AsText(linestring) AS geom,tags::hstore->'maxspeed' AS speed,tags::hstore->'highway' AS type FROM ways",
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
  return(list(roads=roads,type=data$type,speed=data$speed))
}

#' Get graph edges from Lines list and reference raster
#'
#'   iterate on roads to create an "edgelist" of connexions between raster cells
graphEdgesFromLines<-function(roads,baseraster){
  l=roads$roads
  type=roads$type
  speed=roads$speed
  edgelist=list();edgespeed=c();edgetype=c()
  for(i in 1:length(l)){
    if(i%%1000==0){show(i)}
    coords = l[[i]]@Lines[[1]]@coords
    # assume a connection at each vertex, ignores 'tunnel effect' -> ok at these scales
    conn = unique(cellFromXY(baseraster,coords))
    if(length(conn)>1){
      for(j in 1:(length(conn)-1)){
        edgelist=append(edgelist,list(conn[j:(j+1)]))
        edgespeed=append(edgespeed,speed[i]);edgetype=append(edgetype,type[i])
      }
    }
  }
  return(list(edgelist=edgelist,speed=edgespeed,type=edgetype))
}


#' Graph simplification
#'
#'
simplifyGraph<-function(g){
  degrees=degree(g)
  remvertices = V(g)[which(degrees==2)]
  edgestoadd=V(g)[0];vtodelete=V(g)[0]
  edgespeed=c();edgelength=c();edgetype=c()
  while(length(remvertices)>0){
    v=remvertices[1]
    n=neighbors(g,v);prevo=v;prevd=v
    o=n[1];d=n[2];p=c(v,o,d)
    elengths = c();espeeds = c();etypes=c();
    
    # TODO : - length when only v is deleted -
    
    while(max(degree(g,v=o))==2){
      # link o - prevo added to cumulate speed and distance
      e=E(g) [ o %--% prevo];
      elengths=append(elengths,spDistsN1(pts = matrix(c(prevo$x,prevo$y),nrow=1),pt = c(o$x,o$y),longlat = TRUE))
      espeeds=append(espeeds,e$speed);etypes=append(etypes,e$type)
      no=neighbors(g,o);tmpo=o;o=no[which(no!=prevo)];prevo=tmpo;p=append(p,o)
    }
    while(max(degree(g,v=d))==2){
      e=E(g) [ d %--% prevd];
      elengths=append(elengths,spDistsN1(pts = matrix(c(prevd$x,prevd$y),nrow=1),pt = c(d$x,d$y),longlat = TRUE))
      espeeds=append(espeeds,e$speed);etypes=append(etypes,e$type)
      nd=neighbors(g,d);tmpd=d;d=nd[which(nd!=prevd)];prevd=tmpd;p=append(p,d)
    }
    # delete path vertices and add edge
    remvertices=difference(remvertices,p[which(p!=o&p!=d)])
    edgestoadd=append(edgestoadd,c(o$name,d$name))
    edgelength=append(edgelength,sum(elengths))
    edgespeed=append(edgespeed,sum(elengths*as.numeric(espeeds))/sum(elengths))
    type="NA";nt=0;for(tt in unique(etypes)){if(length(which(etypes==tt))>nt){type=tt}}
    edgetype=append(edgetype,type)
    vtodelete=append(vtodelete,p[which(p!=o&p!=d)])
    show(length(remvertices))
  }
  return(list(graph = delete_vertices(g,vtodelete),edgestoadd=edgestoadd,edgelength=edgelength,edgespeed=edgespeed,edgetype=edgetype))
}

#gg<-add_edges(g,edgestoadd)
#vd=V(gg)[0];for(vn in vtodelete$name){vd=append(vd,V(gg)[which(V(gg)$name==vn)])}
#ggg<-delete_vertices(gg,vtodelete)
#ggg<-delete_vertices(gg,V(gg)[which(V(gg)$name %in% vtodelete$name)])
#add_edges(gg,V(gg)[which(V(gg)$name %in% edgestoadd$name)


insertEdgeQuery<-function(o,d,length,speed,type){
  
  # TODO : index to not duplicate (-> necessary ? )
  
  return(paste0(
     "INSERT INTO links (origin,destination,length,speed,roadtype,geography) values (",
     #"'",o$name,d$name,type,"',
     o$name,",",d$name,",",length,",",speed,",'",type,"',",
     "ST_GeographyFromText('LINESTRING(",o$x," ",o$y,",",d$x," ",d$y,")'));"
    )
  )
}

#'
#' 
#' insertion into simplified database : insert into links (id,origin,destination,geography) values ('1',10,50,ST_GeographyFromText('LINESTRING(-122.33 47.606, 0.0 51.5)')); 
exportGraph<-function(sg){
  # get simpl base connection
  con = dbConnect(dbDriver("PostgreSQL"), dbname="osm_simpl",user="Juste",host="localhost" )
  
  dbSendQuery(con,"BEGIN TRANSACTION;")
  
  # first insert graph edges
  for(e in E(sg$graph)){
    dbSendQuery(con,)
  }
  
  graph=sg$graph
  sg$edgespeed[which(is.nan(sg$edgespeed))]=0
  sg$edgespeed[which(is.na(sg$edgespeed))]=0
  # then supplementary edges
  for(i in seq(from=1,to=length(sg$edgestoadd),by=2)){
    o=V(graph)[[sg$edgestoadd[i]]];d=V(graph)[[sg$edgestoadd[i+1]]]
    dbSendQuery(con,insertEdgeQuery(o,d,sg$edgelength[1+(i-1)/2],sg$edgespeed[1+(i-1)/2],sg$edgetype[1+(i-1)/2]))
  }
  
  dbCommit(con)
  dbDisconnect(con)
  
}



