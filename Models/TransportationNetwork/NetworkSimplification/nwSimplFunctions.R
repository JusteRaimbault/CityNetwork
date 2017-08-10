
# nw simplification functions


#library(RPostgreSQL)
#library(rgeos)
#library(rgdal)
library(raster)
library(igraph)
library(RMongo)




#' 
#' @description get mask raster with good resolution
#' 
getRaster<-function(file,newresolution=0,reproject=F){
  provraster <- raster(file)
  if(reproject==F&newresolution==0){return(provraster)}
  if(reproject==F){
    return(raster(extent(provraster),nrow=nrow(provraster)*yres(provraster)/newresolution,ncol=ncol(provraster)*xres(provraster)/newresolution,crs=crs(provraster)))
  }else{
    ext =extent(provraster)
    xmin=ext@xmin;xmax=ext@xmax;ymin=ext@ymin;ymax=ext@ymax
    wgs84=CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
    wgs84extent = extent(spTransform(SpatialPoints(matrix(data=c(xmin,ymin,xmax,ymax),ncol=2,byrow=T),crs(provraster)),wgs84))
    return(raster(wgs84extent,nrow=nrow(provraster)*yres(provraster)/newresolution,ncol=ncol(provraster)*xres(provraster)/newresolution,crs=wgs84))
  }
}



#'
#'
#' @description Get coordinates of cells
getCoords<-function(r,xmin,ymin,xmax,ymax,cells){
  rows = seq(from=rowFromY(r,ymax),to=rowFromY(r,ymin),by=cells)
  cols = seq(from=colFromX(r,xmin),to=colFromX(r,xmax),by=cells)
 
  show(rows)
  show(cols)
  
  coords = coordsFromIndexes(r,rows[1:(length(rows)-1)],(rows-1)[2:length(rows)],cols[1:(length(cols)-1)],(cols-1)[2:length(cols)])

  return(coords)
}

#'
#' @param cells : area size in number of cells
#' @param offset : number of cells between two consecutive areas
getCoordsOffset<-function(r,xmin,ymin,xmax,ymax,cells,offset){
  rows_min = seq(from=rowFromY(r,ymax),to=rowFromY(r,ymin)-cells,by=offset)
  rows_max = seq(from=rowFromY(r,ymax)+cells,to=rowFromY(r,ymin),by=offset)-1
  cols_min = seq(from=colFromX(r,xmin),to=colFromX(r,xmax)-cells,by=offset)
  cols_max = seq(from=colFromX(r,xmin)+cells,to=colFromX(r,xmax),by=offset)-1
  show(length(rows_min))
  show(length(cols_min))
  coords = coordsFromIndexes(r,rows_min,rows_max,cols_min,cols_max)
  return(coords)
}

#'
#' @description aux function (used also in merge sequences)
#' @requires |rows_min|=|rows_max| ; |cols_min|=|cols_max|
coordsFromIndexes<-function(densraster,rows_min,rows_max,cols_min,cols_max){
  coords = matrix(0,length(rows_min)*length(cols_min),4)#data.frame()
  k=1
  xr=xres(densraster);yr=yres(densraster)
  for(i in 1:length(rows_min)){
    show(paste0("  coords : row ",i," / ",length(rows_min)))
    for(j in 1:length(cols_min)){
      topleft = xyFromCell(densraster,cellFromRowCol(densraster,rows_min[i],cols_min[j]))
      bottomright = xyFromCell(densraster,cellFromRowCol(densraster,rows_max[i],cols_max[j]))
      #coords = rbind(coords,c(topleft[1]-xr/2,topleft[2]+yr/2,bottomright[1]+xr/2,bottomright[2]-yr/2))
      coords[k,]=c(topleft[1]-xr/2,topleft[2]+yr/2,bottomright[1]+xr/2,bottomright[2]-yr/2)
      k=k+1
    }
  }
  # names : error ?
  #names(coords)<-c("lonmin","latmax","lonmax","latmin")
  coords = data.frame(coords)
  return(coords)
}

#'
#'
#' @description Get independent merging seqs from coordinates.
#' 
getMergingSequences<-function(densraster,lonmin,latmin,lonmax,latmax,ncells){
  res = list()
  rows = seq(from=rowFromY(densraster,latmax),to=rowFromY(densraster,latmin),by=ncells)
  cols = seq(from=colFromX(densraster,lonmin),to=colFromX(densraster,lonmax),by=ncells)
  
  # basic independent partition
  c1=coordsFromIndexes(densraster,rows[seq(from=1,to=(length(rows)-2),by=2)],(rows-1)[seq(from=2,to=(length(rows)-1),by=2)],cols[seq(from=1,to=(length(cols)-1),by=1)],(cols-1)[seq(from=2,to=length(cols),by=1)])
  c2=coordsFromIndexes(densraster,rows[seq(from=2,to=(length(rows)-1),by=2)],(rows-1)[seq(from=3,to=length(rows),by=2)],cols[seq(from=1,to=(length(cols)-1),by=1)],(cols-1)[seq(from=2,to=length(cols),by=1)])
  #show(c1[min(nrow(c1),nrow(c2)),1]);show(c2[min(nrow(c1),nrow(c2)),1])
  res[[1]] = cbind(c1[1:min(nrow(c1),nrow(c2)),],c2[1:min(nrow(c1),nrow(c2)),])
  c1=coordsFromIndexes(densraster,rows[seq(from=2,to=(length(rows)-2),by=2)],(rows-1)[seq(from=3,to=(length(rows)-1),by=2)],cols[seq(from=1,to=(length(cols)-1),by=1)],(cols-1)[seq(from=2,to=length(cols),by=1)])
  c2=coordsFromIndexes(densraster,rows[seq(from=3,to=(length(rows)-1),by=2)],(rows-1)[seq(from=4,to=length(rows),by=2)],cols[seq(from=1,to=(length(cols)-1),by=1)],(cols-1)[seq(from=2,to=length(cols),by=1)])
  res[[2]] = cbind(c1[1:min(nrow(c1),nrow(c2)),],c2[1:min(nrow(c1),nrow(c2)),])
  c1=coordsFromIndexes(densraster,rows[seq(from=1,to=(length(rows)-1),by=1)],(rows-1)[seq(from=2,to=length(rows),by=1)],cols[seq(from=1,to=(length(cols)-2),by=2)],(cols-1)[seq(from=2,to=(length(cols)-1),by=2)])
  c2=coordsFromIndexes(densraster,rows[seq(from=1,to=(length(rows)-1),by=1)],(rows-1)[seq(from=2,to=length(rows),by=1)],cols[seq(from=2,to=(length(cols)-1),by=2)],(cols-1)[seq(from=3,to=length(cols),by=2)])
  res[[3]] = cbind(c1[1:min(nrow(c1),nrow(c2)),],c2[1:min(nrow(c1),nrow(c2)),])
  c1=coordsFromIndexes(densraster,rows[seq(from=1,to=(length(rows)-1),by=1)],(rows-1)[seq(from=2,to=length(rows),by=1)],cols[seq(from=2,to=(length(cols)-2),by=2)],(cols-1)[seq(from=3,to=(length(cols)-1),by=2)])
  c2=coordsFromIndexes(densraster,rows[seq(from=1,to=(length(rows)-1),by=1)],(rows-1)[seq(from=2,to=length(rows),by=1)],cols[seq(from=3,to=(length(cols)-1),by=2)],(cols-1)[seq(from=4,to=length(cols),by=2)])
  res[[4]] = cbind(c1[1:min(nrow(c1),nrow(c2)),],c2[1:min(nrow(c1),nrow(c2)),])
  return(res)
}

# DEBUG
#apply(cbind(c1[1:min(nrow(c1),nrow(c2)),],c2[1:min(nrow(c1),nrow(c2)),]),2,diff)
#apply(c1,2,diff)
#apply(c2,2,diff)


#' 
#' @description Get road linestrings (SPatialLines) within given extent
#' @param latmin,lonmin,latmax,lonmax bbox
#' @param tags list of tag values (for key highway)
#' @requires global variables : osmdb, dbport
#' 
linesWithinExtent<-function(lonmin,latmin,lonmax,latmax,tags,osmdb=global.osmdb,dbuser=global.dbuser,dbport=global.dbport,dbhost=global.dbhost){
  #show(paste0('getting lines within [',lonmin,'-',lonmax,']x[',latmin,'-',latmax,'] on db ',osmdb))
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
  #show(q);
  query = dbSendQuery(pgsqlcon,q)
  data = fetch(query,n=-1)
  geoms = data$geom
  roads=list();k=1
  #show(paste0(' -> ',length(geoms),' segments'))
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

#' 
#' @description Get graph edges from Lines list and reference raster
#'     iterate on lines to create an "edgelist" of connexions between raster cells
graphEdgesFromLines<-function(lines,baseraster,verbose=F){
  l=lines$roads
  type=lines$type
  speed=lines$speed
  edgelist=list();edgespeed=c();edgetype=c()
  for(i in 1:length(l)){
    if(i%%1000==0&verbose==T){show(i)}
    coords = l[[i]]@Lines[[1]]@coords
    # assume a connection at each vertex, ignores 'tunnel effect'
    #  -> ok at these scales for roads
    # for train, careful with LGV
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
#' @description get edge list from a shp file given the simplification resolution
graphFromSpdf<-function(spdf,resolution,lonlat=F){
  bounds = bbox(spdf);ext=extent(bounds[1,1],bounds[1,2],bounds[2,1],bounds[2,2])
  r = raster(nrow = floor((ext[4]-ext[3])/resolution),ncol = floor((ext[2]-ext[1])/resolution),crs=crs(spdf),ext=ext,resolution=resolution)
  lines = list(roads=spdf@lines,type=rep("NA",length(spdf)),speed=spdf$speed)
  edgelist = graphEdgesFromLines(lines,r)
  return(graphFromEdges(edgelist,r,from_query=T,lonlat=lonlat))
}


#'
#' @description default global parameter values
defaultDBParams<-function(dbsystem='',dbhost='',dbport=0,dbname=''){
  return(list(
    dbsystem=ifelse(nchar(dbsystem)>0,dbsystem,'mongo'),
    dbhost=ifelse(nchar(dbhost)>0,dbhost,'127.0.0.1'),
    dbport=ifelse(dbport>0,dbport,29019),
    dbname=ifelse(nchar(dbname)>0,dbname,'china')
  ))
}

#'
#' @description Retrieve graph from a simplified base (basic request)
#' 
graphEdgesFromBase<-function(lonmin,latmin,lonmax,latmax,dbparams=defaultDBParams()){
    # pgsql params : dbname,dbport=global.dbport,dbuser=global.dbuser,dbhost=global.dbhost
  if(!'dbsystem'%in%names(dbparams)){stop('error : db config')}
  if(dbparams['dbsystem']=='pgsql'){
    dbname=dbparams['dbname'];dbport=dbparams['dbport'];dbuser=dbparams['dbuser'];dbhost=dbparams['dbhost']
    pgsqlcon = dbConnect(dbDriver("PostgreSQL"), dbname=dbname,user=dbuser,port=dbport,host=dbhost)
    q = paste0(
      "SELECT origin,destination,length,speed,roadtype FROM links",
      " WHERE ST_Intersects(ST_MakeEnvelope(",lonmin,",",latmin,",",lonmax,",",latmax,",4326),","geography);")
    show(q)
    query = dbSendQuery(pgsqlcon,q)
    data = fetch(query,n=-1)
    dbDisconnect(pgsqlcon)
  }
  if(dbparams['dbsystem']=='mongo'){
    #show(paste0('Connecting to ',dbparams['dbname'],' at ',dbparams['dbhost'],' port ',dbparams['dbport']))
    #mongo <- mongoDbConnect(dbparams['dbname'],dbparams['dbhost'],dbparams['dbport'])
    query = paste0('{"geometry":{$geoWithin:{$geometry:{type:"Polygon",coordinates:[[[',lonmin,',',latmin,'],[',lonmin,',',latmax,'],[',lonmax,',',latmax,'],[',lonmax,',',latmin,'],[',lonmin,',',latmin,']]]}}}}')
    show(query)
    fields = '{"ORIGIN":1,"DESTINATIO":1,"LENGTH":1,"SPEED":1,"ROADTYPE":1}'
    data <- dbGetQueryForKeys(mongo,'network',query,fields)
    dbDisconnect(mongo)
    show(paste0('data size : ',length(data)))
    if(length(data)>0){names(data)<-c("origin","destination","length","speed","roadtype")}
  }
  
  if(length(data)==0){return(list())}
  res=list(edgelist=data.frame(from=data$origin,to=data$destination),speed=data$speed,type=data$speed,length=data$length)
  return(res)
}


#' 
#' @description Construct graph given edgelist
#'  
graphFromEdges<-function(edgelist,densraster,from_query=TRUE,lonlat=T){
  if(is.null(edgelist$edgelist)){return(make_empty_graph())}
  if(from_query==TRUE){edgesmat=matrix(data=as.character(unlist(edgelist$edgelist)),ncol=2,byrow=TRUE);}
  else{edgesmat=edgelist$edgelist}
  #show(edgesmat)
  validedges=!is.na(edgesmat[,1])&!is.na(edgesmat[,2])
  edgesmat=edgesmat[validedges,]
  edgelist$speed[is.na(edgelist$speed)]=0
  edgelist$type[is.na(edgelist$type)]=""
  g = graph_from_data_frame(data.frame(edgesmat,speed=edgelist$speed[validedges],type=edgelist$type[validedges]),directed=FALSE)
  #show(g)
  gcoords = xyFromCell(densraster,as.numeric(V(g)$name))
  V(g)$x=gcoords[,1];V(g)$y=gcoords[,2]
  #show(g)
  #show(edgelist$length)
  if(!is.null(edgelist$length)){E(g)$length=edgelist$length}
  else{
    elengths=c()
    bothends = ends(g,E(g),names=FALSE)
    x1 = V(g)$x[bothends[,1]];x2 = V(g)$x[bothends[,2]]
    y1 = V(g)$y[bothends[,1]];y2 = V(g)$y[bothends[,2]]
    for(k in 1:length(x1)){
	#show(V(g)$name[bothends[k,1]]);show(V(g)$name[bothends[k,2]])      
	#show(paste0(x1[k],x2[k],y1[k],y2[k]))
      elengths=append(elengths,spDistsN1(pts = matrix(c(x1[k],y1[k]),nrow=1),pt = c(x2[k],y2[k]),longlat = lonlat))
    }
    E(g)$length=elengths;
  }
  
  gg=simplify(g,edge.attr.comb="min")
  return(gg)
}


#'
#' @description Graph simplification algorithm
#' @param g igraph object
#' @param bounds coordinates of boundaries
#' @param xr x resolution
#' @param yr y resolution
#' 
simplifyGraph<-function(g,bounds=NULL,xr=0,yr=0,direct=T){
  if(is.null(bounds)|direct==T){
    # full graph simplification
    xr = 10000;yr=10000;
    bounds=c(min(V(g)$x),min(V(g)$y),max(V(g)$x),max(V(g)$y))
  }
  
  # select graph strictly within bounds
  #  -- before that : keep crossing links to be added --
  joint_vertices = V(g)$x>bounds[1]+xr&V(g)$x<bounds[3]-xr&V(g)$y>bounds[2]+yr&V(g)$y<bounds[4]-yr
  bound_vertices = (V(g)$x>bounds[3]-xr&V(g)$x<bounds[3]&V(g)$y>bounds[2]-yr&V(g)$y<bounds[4]+yr)|
                   (V(g)$x<bounds[1]+xr&V(g)$x>bounds[1]&V(g)$y>bounds[2]-yr&V(g)$y<bounds[4]+yr)|
                   (V(g)$x>bounds[1]-xr&V(g)$x<bounds[3]+xr&V(g)$y<bounds[2]+yr&V(g)$y>bounds[2])|
                   (V(g)$x>bounds[1]-xr&V(g)$x<bounds[3]+xr&V(g)$y>bounds[4]-yr&V(g)$y<bounds[4])
  ext_vertices = V(g)$x>bounds[3]|(V(g)$x<bounds[1])|(V(g)$x>bounds[1]&V(g)$x<bounds[3]&(V(g)$y<bounds[2]|V(g)$y>bounds[4]))
  degrees=degree(g)
  #g = induced_subgraph(graph = g,vids = joint_vertices)
  # condition on edges and not vertices
  joint_edges = E(g)[(joint_vertices %--% joint_vertices)|(bound_vertices %--% joint_vertices)|(joint_vertices %--% bound_vertices)|(joint_vertices %--% ext_vertices)|(ext_vertices%--% joint_vertices)|(bound_vertices %--% bound_vertices)|((bound_vertices&degrees>2) %--% ext_vertices)|(ext_vertices %--% (bound_vertices&degrees>2))]
  out_edges = E(g)[((bound_vertices&degrees<=2) %--% ext_vertices)|(ext_vertices %--% (bound_vertices&degrees<=2))]
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
    # check speed combination, strange results for train network
    edgespeed=append(edgespeed,sum(elengths*as.numeric(espeeds))/sum(elengths))
    type="NA";nt=0;for(tt in unique(etypes)){if(length(which(etypes==tt))>nt){type=tt}}
    edgetype=append(edgetype,type)
    vtodelete=append(vtodelete,p[which(p!=o&p!=d)])
    show(length(remvertices))
  }
  if(length(edgestoadd)==0){edgestoadd=c()}
  # do not delete vertices extremities of edges to add
  for(e in edgestoadd){vtodelete=difference(vtodelete,vtodelete[vtodelete$name==e])}
  if(direct==F){
    return(list(graph = delete_vertices(g,vtodelete),edgestoadd=edgestoadd,edgelength=edgelength,edgespeed=edgespeed,edgetype=edgetype))
  }else{
    #show(edgespeed)
    g=delete_vertices(g,vtodelete)
    g=add_edges(g,edgestoadd,attr = list(speed=edgespeed))
    g=simplify(g,edge.attr.comb = "min")
    comps=components(g);cmax = which(comps$csize==max(comps$csize))
    g = induced_subgraph(g,which(comps$membership==cmax))
    return(g)
  }
}

#'
#' @description merge two graphs
mergeGraphs<-function(l1,l2){
  if(length(l1)==0){return(l2)}
  g=l1$graph+l2$graph
  #show(as.numeric(!is.na(V(g)$x_1)));show(as.numeric(!is.na(V(g)$x_2)))
  x=rep(0,length(V(g)$x_1));y=rep(0,length(V(g)$y_1))
  x[!is.na(V(g)$x_1)]=V(g)$x_1[!is.na(V(g)$x_1)];x[!is.na(V(g)$x_2)]=V(g)$x_2[!is.na(V(g)$x_2)]
  y[!is.na(V(g)$y_1)]=V(g)$y_1[!is.na(V(g)$y_1)];y[!is.na(V(g)$y_2)]=V(g)$y_2[!is.na(V(g)$y_2)]
  V(g)$x = x;V(g)$y = y
  return(list(graph=g,edgestoadd=c(l1$edgestoadd,l2$edgestoadd),edgelength=c(l1$edgelength,l2$edgelength),edgespeed=c(l1$edgespeed,l2$edgespeed),edgetype=c(l1$edgetype,l2$edgetype)))
}


#'
#' @description Speed as numeric for osm road network (in km.h-1, conversion from mph if needed)
#' 
normalizedSpeed <- function(s){
  if(!is.na(as.numeric(s))){return(as.numeric(s))}
  sr=gsub(x = s," ","")
  if(grepl("mph",sr)){return(as.numeric(gsub(x = sr,"mph",""))*1.609)}
  else{return(0)}
}

#'
#' @description postgis insertion query
#' 
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





#' 
#' @description insertion into simplified database
#'              "insert into links (id,origin,destination,geography) values ('1',10,50,ST_GeographyFromText('LINESTRING(-122.33 47.606, 0.0 51.5)'));"
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
      if(length(sg$edgestoadd)>0){
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
    }

    #dbCommit(con)
    
    dbDisconnect(con)
  }
}


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
    #show(edgelist$edgelist)
    res$gg= graphFromEdges(edgelist,densraster)
    if(simplify==TRUE){  
      res$sg = simplifyGraph(res$gg,bounds = c(lonmin,latmin,lonmax,latmax),xr,yr)
    }
    #show(res)
  }
  return(res)
}





#'
#' @description Given coordinates of two cells, retrieve, merges and exports final graph.
#'              Process :
#'                 - retrieve nw segments from intermediate base, reconstruct common nw
#'                 - simplify graph [check if same function can be used]
mergeLocalGraphs<-function(bbox,xr,yr,dbname){
  lonmin=min(bbox[1],bbox[5]);latmax=max(bbox[2],bbox[6]);lonmax=max(bbox[3],bbox[7]);latmin=min(bbox[4],bbox[8])
  edges = graphEdgesFromBase(lonmin,latmin,lonmax,latmax,dbparams = list(dbname=dbname,dbhost=global.dbhost,dbport=global.dbport,dbhost=global.dbhost,dbuser=global.dbuser))
  res=list()
  if(length(edges$edgelist)>0){
    res$sg = simplifyGraph(graphFromEdges(edges,densraster,from_query = FALSE),bounds=c(lonmin,latmin,lonmax,latmax),xr,yr)
  }
  return(res)
}



#'
#' @description connexify a graph with fixed pace links, with shortest distance link
#'              assumes vertices have x,y coordinates.
#'              Algo : take first component, find smallest dist with all summits outside, iterate
connexify<-function(g,pace=0.0012){
  comps = components(g)
  ncomps = length(sizes(comps))
  while(ncomps > 1){
    d=spDists(matrix(c(V(g)$x[comps$membership==1],V(g)$y[comps$membership==1]),nrow=length(which(comps$membership==1)),byrow = F),
              matrix(c(V(g)$x[comps$membership!=1],V(g)$y[comps$membership!=1]),nrow=length(which(comps$membership!=1)),byrow = F)
              )
    minrow=which.min(apply(d,1,min));mincol=which.min(d[minrow,])
    g=add_edges(g,edges=c(V(g)$name[comps$membership==1][minrow],V(g)$name[comps$membership!=1][mincol]),attr=list(speed=pace,length=d[minrow,mincol]))
    comps = components(g)
    ncomps = length(sizes(comps))
  }
  return(g)
}







