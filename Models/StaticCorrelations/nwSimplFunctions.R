
# nw simplification functions


library(RPostgreSQL)
library(rgeos)
library(rgdal)
library(raster)
library(igraph)





##############'
#'
#' Get coordinates of cells
getCoords<-function(r,xmin,ymin,xmax,ymax,cells){
  rows = seq(from=rowFromY(r,ymax),to=rowFromY(r,ymin),by=cells)
  cols = seq(from=colFromX(r,xmin),to=colFromX(r,xmax),by=cells)
 
  show(rows)
  show(cols)
  
  coords = coordsFromIndexes(r,rows[1:(length(rows)-1)],(rows-1)[2:length(rows)],cols[1:(length(cols)-1)],(cols-1)[2:length(cols)])

  return(coords)
}

#'
#' aux function
#' (used also in merge sequences)
#' 
#' @requires |rows_min|=|rows_max| ; |cols_min|=|cols_max|
coordsFromIndexes<-function(densraster,rows_min,rows_max,cols_min,cols_max){
  coords = data.frame()
  xr=xres(densraster);yr=yres(densraster)
  for(i in 1:length(rows_min)){
    show(paste0("  coords : row ",i," / ",length(rows_min)))
    for(j in 1:length(cols_min)){
      topleft = xyFromCell(densraster,cellFromRowCol(densraster,rows_min[i],cols_min[j]))
      bottomright = xyFromCell(densraster,cellFromRowCol(densraster,rows_max[i],cols_max[j]))
      coords = rbind(coords,c(topleft[1]-xr/2,topleft[2]+yr/2,bottomright[1]+xr/2,bottomright[2]-yr/2))
     }
  }
  # names : error ?
  #names(coords)<-c("lonmin","latmax","lonmax","latmin")
  return(coords)
}

################'
#'
#' Get independent merging seqs from coordinates.
#' 
getMergingSequences<-function(densraster,lonmin,latmin,lonmax,latmax,ncells){
  res = list()
  rows = seq(from=rowFromY(densraster,latmax),to=rowFromY(densraster,latmin),by=ncells)
  cols = seq(from=colFromX(densraster,lonmin),to=colFromX(densraster,lonmax),by=ncells)
  
  # basic independent partition
  res[[1]] = cbind(coordsFromIndexes(densraster,rows,cols,seq(from=2,to=length(rows),by=2),2:length(cols)),coordsFromIndexes(densraster,rows,cols,seq(from=3,to=length(rows),by=2),2:length(cols)))
  res[[2]] = cbind(coordsFromIndexes(densraster,rows,cols,seq(from=3,to=length(rows),by=2),2:length(cols)),coordsFromIndexes(densraster,rows,cols,seq(from=2,to=length(rows),by=2),2:length(cols)))
  res[[3]] = cbind(coordsFromIndexes(densraster,rows,cols,2:length(rows),seq(from=2,to=length(cols),by=2)),coordsFromIndexes(densraster,rows,cols,2:length(rows),seq(from=3,to=length(cols),by=2)))
  res[[4]] = cbind(coordsFromIndexes(densraster,rows,cols,2:length(rows),seq(from=3,to=length(cols),by=2)),coordsFromIndexes(densraster,rows,cols,2:length(rows),seq(from=2,to=length(cols),by=2)))
}





#' #####################
#' Get road linestrings (SPatialLines) within given extent
#'
#' @param latmin,lonmin,latmax,lonmax bbox
#' @param tags list of tag values (for key highway)
#'
#' @requires global variables : osmdb, dbport
#' 
linesWithinExtent<-function(lonmin,latmin,lonmax,latmax,tags,osmdb=global.osmdb,dbuser=global.dbuser,dbport=global.dbport,dbhost=global.dbhost){
  #show(osmdb)
  pgsqlcon = dbConnect(dbDriver("PostgreSQL"), dbname=osmdb,user=dbuser,port=dbport,host=dbhost)
  
  q = paste0(
    "SELECT ST_AsText(linestring) AS geom,tags::hstore->'maxspeed' AS speed,tags::hstore->'highway' AS type FROM ways",
    " WHERE ST_Intersects(ST_MakeEnvelope(",lonmin,",",latmin,",",lonmax,",",latmax,",4326),","linestring)")
  if(length(tags)>0){
    q=paste0(q," AND (")
    for(i in 1:(length(tags)-1)){q=paste0(q,"tags::hstore->'highway'='",tags[i],"' OR ")}
    q=paste0(q,"tags::hstore->'highway'='",tags[length(tags)],"')")
  }
  q=paste0(q,";")
  query = dbSendQuery(pgsqlcon,q)
  data = fetch(query,n=-1)
  geoms = data$geom
  roads=list();k=1
  for(i in 1:length(geoms)){
    r=try(readWKT(geoms[i])@lines[[1]],silent=TRUE)
    if(!inherits(r,"try-error")){
       r@ID=as.character(i)
       roads[[k]]=r;k=k+1
    }
  } 
  
  dbDisconnect(pgsqlcon)
  
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

#'
#' Retrieve graph from a simplified base (basic request)
#' 
graphEdgesFromBase<-function(lonmin,latmin,lonmax,latmax,dbname,dbport=global.dbport,dbuser=global.dbuser,dbhost=global.dbhost){
  pgsqlcon = dbConnect(dbDriver("PostgreSQL"), dbname=dbname,user=dbuser,port=dbport,host=dbhost)
  q = paste0(
    "SELECT origin,destination,length,speed,roadtype FROM links",
    " WHERE ST_Intersects(ST_MakeEnvelope(",lonmin,",",latmin,",",lonmax,",",latmax,",4326),","geography);")
  query = dbSendQuery(pgsqlcon,q)
  data = fetch(query,n=-1)
  res=list(edgelist=data.frame(from=data$origin,to=data$destination),speed=data$speed,type=data$speed,length=data$length)
  return(res)
}


############'
#'  
#'  Construct graph given edgelist
#'  
graphFromEdges<-function(edgelist,densraster){
  edgesmat=matrix(data=as.character(unlist(edgelist$edgelist)),ncol=2,byrow=TRUE);
  g = graph_from_data_frame(data.frame(edgesmat,speed=edgelist$speed,type=edgelist$type),directed=FALSE)
  gcoords = xyFromCell(densraster,as.numeric(V(g)$name))
  V(g)$x=gcoords[,1];V(g)$y=gcoords[,2]
  gg=simplify(g)
  return(gg)
}


####################
#'
#' Graph simplification algorithm
#'
#'  - the more spaghetti code EVER written - beuuargh
#'
simplifyGraph<-function(g,bounds,xr,yr){
  # select graph strictly within bounds
  #  -- before that : keep crossing links to be added --
  joint_vertices = V(g)$x>bounds[1]+xr&V(g)$x<bounds[3]-xr&V(g)$y>bounds[2]+yr&V(g)$y<bounds[4]-yr
  bound_vertices = (V(g)$x>bounds[3]-xr&V(g)$x<bounds[3]&V(g)$y>bounds[2]-yr&V(g)$y<bounds[4]+yr)|
                   (V(g)$x<bounds[1]+xr&V(g)$x>bounds[1]&V(g)$y>bounds[2]-yr&V(g)$y<bounds[4]+yr)|
                   (V(g)$x>bounds[1]-xr&V(g)$x<bounds[3]+xr&V(g)$y<bounds[2]+yr&V(g)$y>bounds[2])|
                   (V(g)$x>bounds[1]-xr&V(g)$x<bounds[3]+xr&V(g)$y>bounds[4]-yr&V(g)$y<bounds[4])
  ext_vertices = V(g)$x>bounds[3]|(V(g)$x<bounds[1])|(V(g)$x>bounds[1]&V(g)$x<bounds[3]&(V(g)$y<bounds[2]|V(g)$y>bounds[4]))
  #g = induced_subgraph(graph = g,vids = joint_vertices)
  # condition on edges and not vertices
  joint_edges = E(g)[joint_vertices %--% joint_vertices]
  out_edges = E(g)[(V(g) %--% bound_vertices)|(bound_vertices %--% V(g))|(joint_vertices %--% ext_vertices)|(ext_vertices%--% joint_vertices)]
  edgestoadd=V(g)[0];edgespeed=c();edgelength=c();edgetype=c()
  for(oe in out_edges){eds = ends(g,oe);edgestoadd=append(edgestoadd,c(eds[1,1],eds[1,2]));edgespeed=append(edgespeed,E(g)[oe]$speed);edgelength=append(edgelength,E(g)[oe]$length);edgetype=append(edgetype,E(g)[oe]$type)}
  
  g = subgraph.edges(g,joint_edges,delete.vertices = FALSE)
  degrees=degree(g)
  remvertices = V(g)[which(degrees==2)]
  vtodelete=V(g)[0] # empty vertex sequence

  while(length(remvertices)>0){
    v=remvertices[1]
    n=neighbors(g,v);prevo=v;prevd=v
    o=n[1];d=n[2];p=c(v,o,d)
    elengths = c();espeeds = c();etypes=c();
    
    # - length when  o or d are already extremities -
    #  [should not happen with simplified graph]
    if(max(degree(g,v=o))>2){e=E(g) [ o %--% v];elengths=append(elengths,spDistsN1(pts = matrix(c(v$x,v$y),nrow=1),pt = c(o$x,o$y),longlat = TRUE));espeeds=append(espeeds,e$speed);etypes=append(etypes,e$type)}
    if(max(degree(g,v=d))>2){e=E(g) [ d %--% v];elengths=append(elengths,spDistsN1(pts = matrix(c(v$x,v$y),nrow=1),pt = c(d$x,d$y),longlat = TRUE));espeeds=append(espeeds,e$speed);etypes=append(etypes,e$type)}
    
    while(max(degree(g,v=o))==2){
      # link o - prevo added to cumulate speed and distance
      e=E(g) [ o %--% prevo];
      elengths=append(elengths,spDistsN1(pts = matrix(c(prevo$x,prevo$y),nrow=1),pt = c(o$x,o$y),longlat = TRUE))
      espeeds=append(espeeds,e$speed);etypes=append(etypes,e$type)
      no=neighbors(g,o);tmpo=o;o=no[which(no!=prevo)];prevo=tmpo;
      if(length(o)==0) break;
      if(o %in% p) break;
      p=append(p,o)
    }
    while(max(degree(g,v=d))==2){
      e=E(g) [ d %--% prevd];
      elengths=append(elengths,spDistsN1(pts = matrix(c(prevd$x,prevd$y),nrow=1),pt = c(d$x,d$y),longlat = TRUE))
      espeeds=append(espeeds,e$speed);etypes=append(etypes,e$type)
      nd=neighbors(g,d);tmpd=d;d=nd[which(nd!=prevd)];prevd=tmpd;
      if(length(d)==0) break;
      if(d %in% p) break ;
      p=append(p,d)
    }
    # delete path vertices and add edge
    remvertices=difference(remvertices,p[which(p!=o&p!=d)])
    # delete v anyway to avoid infinite loop when a node has a self loop
    remvertices=difference(remvertices,c(v))
    #
    edgestoadd=append(edgestoadd,c(o$name,d$name))
    edgelength=append(edgelength,sum(elengths))
    edgespeed=append(edgespeed,sum(elengths*as.numeric(espeeds))/sum(elengths))
    type="NA";nt=0;for(tt in unique(etypes)){if(length(which(etypes==tt))>nt){type=tt}}
    edgetype=append(edgetype,type)
    vtodelete=append(vtodelete,p[which(p!=o&p!=d)])
    show(length(remvertices))
  }
  # do not delete vertices extremities of edges to add
  for(e in edgestoadd){vtodelete=difference(vtodelete,vtodelete[vtodelete$name==e])}
  return(list(graph = delete_vertices(g,vtodelete),edgestoadd=edgestoadd,edgelength=edgelength,edgespeed=edgespeed,edgetype=edgetype))
}


#'
#' Speed as numeric (in km.h-1)
normalizedSpeed <- function(s){
  if(!is.na(as.numeric(s))){return(as.numeric(s))}
  sr=gsub(x = s," ","")
  if(grepl("mph",sr)){return(as.numeric(gsub(x = sr,"mph",""))*1.609)}
  else{return(0)}
}

#' insertion query
insertEdgeQuery<-function(o,d,length,speed,type){
  
  #  index to not duplicate : UNIQUE INDEX on o,d,type
  if(is.na(length))length=0.1
  
  return(paste0(
     "INSERT INTO links (origin,destination,length,speed,roadtype,geography) values (",
     #"'",o$name,d$name,type,"',
     o$name,",",d$name,",",length,",",normalizedSpeed(speed),",'",type,"',",
     "ST_GeographyFromText('LINESTRING(",o$x," ",o$y,",",d$x," ",d$y,")'));"
    )
  )
}




####################'
#' 
#' insertion into simplified database
#'   "insert into links (id,origin,destination,geography) values ('1',10,50,ST_GeographyFromText('LINESTRING(-122.33 47.606, 0.0 51.5)'));"
#'
exportGraph<-function(sg,dbname,dbuser=global.dbuser,dbport=global.dbport,dbhost=global.dbhost){
  if(!is.null(sg)){
    # get simpl base connection
    con = dbConnect(dbDriver("PostgreSQL"), dbname=dbname,user=dbuser,port=dbport,host=dbhost)
    
    if(!is.null(sg$graph)){graph=sg$graph}
    else{graph=sg}
    
    #dbGetQuery(con,"BEGIN TRANSACTION;")
    
    E(graph)$speed[which(is.null(E(graph)$speed))]=0
    E(graph)$speed[which(is.na(E(graph)$speed))]=0
    # first insert graph edges
    for(i in E(graph)){
      e=E(graph)[i]
      vs = V(graph)[ends(graph,e)];o=vs[1];d=vs[2];
      speed=e$speed;type=e$type
      if(length(speed)==0)speed=90
      if(length(type)==0)type="primary"
      length=spDistsN1(pts = matrix(c(o$x,o$y),nrow=1),pt = c(d$x,d$y),longlat = TRUE)
      query=insertEdgeQuery(o,d,length,speed,type)
      #show(query)
      try(dbSendQuery(con,query))
    }
    
    # TODO : finish transaction here and begin new ?
    

    if(!is.null(sg$edgestoadd)){

      if(!is.null(sg$edgestoadd)){
        sg$edgespeed[which(is.nan(sg$edgespeed))]=0
        sg$edgespeed[which(is.na(sg$edgespeed))]=0
      }
      
      # # then supplementary edges
      for(i in seq(from=1,to=length(sg$edgestoadd),by=2)){
        o=V(graph)[[sg$edgestoadd[i]]];d=V(graph)[[sg$edgestoadd[i+1]]]
        try(dbSendQuery(con,insertEdgeQuery(o,d,sg$edgelength[1+(i-1)/2],sg$edgespeed[1+(i-1)/2],sg$edgetype[1+(i-1)/2])))
      }

    }

    #dbCommit(con)
    
    dbDisconnect(con)
  }
}


#####################'
#'
#'
constructLocalGraph<-function(lonmin,latmin,lonmax,latmax,tags,xr,yr,simplify=TRUE){
  roads<-linesWithinExtent(lonmin,latmin,lonmax,latmax,tags)
  show(paste0("Constructing graph for box : ",lonmin,',',latmin,',',lonmax,',',latmax))
  show(paste0("   size (roads number) : ",length(roads$roads)))
  res=list()
  if(length(roads$roads)>0){
    edgelist <- graphEdgesFromLines(roads = roads,baseraster = densraster)
    show(paste0("   size (graph size) : ",length(edgelist$edgelist)))
    res$gg= graphFromEdges(edgelist,densraster)
    if(simplify==TRUE){  
      res$sg = simplifyGraph(res$gg,bounds = c(lonmin,latmin,lonmax,latmax),xr,yr)
    }
  }
  return(res)
}





########################'
#'
#' Given coordinates of two cells, retrieve, merges and exports final graph.
#'
#'  Process :
#'   - retrieve nw segments from intermediate base, reconstruct common nw
#'   - simplify graph [check if same function can be used]
mergeLocalGraphs<-function(bbox,destdb_prov=global.destdb_prov){
  lonmin=min(bbox[1],bbox[5]);latmax=max(bbox[2],bbox[6]);lonmax=max(bbox[3],bbox[7]);latmin=min(bbox[4],bbox[8])
  edges = graphEdgesFromBase(lonmin,latmin,lonmax,latmax,dbname=destdb_prov)
  res=list()
  if(length(edges$edgelist)>0){
    res$sg = simplifyGraph(graphFromEdges(edges,densraster),bounds=c(lonmin,latmin,lonmax,latmax))
  }
  return(res)
}







