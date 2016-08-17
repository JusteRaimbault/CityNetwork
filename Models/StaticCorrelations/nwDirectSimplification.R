
# direct simplification

#
# assumes a full osmdb ; cuts it into coords bbox,
#   parallelized in a parfor loop
#

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))

source('nwSimplFunctions.R')

densraster <- raster(paste0(Sys.getenv("CN_HOME"),"/Data/PopulationDensity/raw/density_wgs84.tif"))
xr=xres(densraster);yr=yres(densraster)

latmin=extent(densraster)@ymin;latmax=extent(densraster)@ymax;
lonmin=extent(densraster)@xmin;lonmax=extent(densraster)@xmax

latmin=46.34;latmax=48.94;lonmin=0.0;lonmax=3.2 # coordinates for db 'centre'
#latmin=49.4;latmax=50.25;lonmin=5.65;lonmax=6.6 # coordinates for db 'luxembourg'
#latmin=49.9;latmax=50.183488;lonmin=5.7300013;lonmax=6.53 # coordinates for db 'luxembourg'

#r=raster(nrows=floor((latmax-latmin)*2000),ncols=floor((lonmax-lonmin)*2000),xmn=lonmin,xmx=lonmax,ymn=latmin,ymx=latmax,crs=crs(densraster))
#densraster=r

ncells = 200

# get coordinates
coords <- getCoords(densraster,lonmin,latmin,lonmax,latmax,ncells)

# export grid for viz
# gridlines=list();i=1
# for(x in unique(c(coords[,1],coords[,3]))){gridlines[[i]]=Lines(Line(cbind(c(x,x),c(latmin,latmax))),as.character(i));i=i+1}
# for(y in unique(c(coords[,2],coords[,4]))){gridlines[[i]]=Lines(Line(cbind(c(lonmin,lonmax),c(y,y))),as.character(i));i=i+1}
# writeOGR(obj = SpatialLinesDataFrame(SpatialLines(LinesList = gridlines,proj4string = crs(densraster)),data.frame(ID=sapply(gridlines,function(x){x@ID})),match.ID = FALSE),
#        dsn='testlight',layer = 'grid_centre',driver = 'ESRI Shapefile',overwrite_layer = TRUE
#        )

tags=c("motorway","trunk","primary","secondary","tertiary","unclassified","residential")

# db config
global.osmdb='europe';global.dbport=5433;global.dbuser="juste";global.dbhost=""
#global.osmdb='centre';global.dbport=5433;global.dbuser="Juste";global.dbhost="localhost"

# destination bases
global.destdb_full='nw_full';global.destdb_prov='nw_prov';global.destdb_simpl='nw_simpl'

# reinit dbs
#system('./runtest.sh')
#system(paste0('./setupDB.sh ',global.destdb_full))
#system(paste0('./setupDB.sh ',global.destdb_prov))
#system(paste0('./setupDB.sh ',global.destdb_simpl))

library(doParallel)
cl <- makeCluster(20,outfile='log')
#cl <- makeCluster(4,outfile='log')
registerDoParallel(cl)

startTime = proc.time()[3]

##
# construction of local graphs

#res <- foreach(i=1:nrow(coords)) %dopar% {
#for(i in 1:nrow(coords)){
#  source('nwSimplFunctions.R')
#  #show(paste0(i,' / ',nrow(coords)))
#  lonmin=coords[i,1];lonmax=coords[i,3];latmin=coords[i,4];latmax=coords[i,2]
#  #localGraph = constructLocalGraph(lonmin,latmin,lonmax,latmax,tags,xr,yr,simplify=FALSE)
#  #if(!is.null(localGraph$gg)){return(vcount(localGraph$gg))}else{return(0)}
#  localGraph = constructLocalGraph(lonmin,latmin,lonmax,latmax,tags,xr,yr)
#  #return(vcount(localGraph$gg))
#  exportGraph(localGraph$gg,dbname=global.destdb_full)
#  exportGraph(localGraph$sg,dbname=global.destdb_prov)
#}

#save(res,file='testlight/sizes.Rdata')

#system('pgsql2shp -f testlight/centre_full -p 5433 nwtest_full links')
#system('pgsql2shp -f testlight/centre_prov -p 5433 nwtest_prov links')
#stopCluster(cl)

##
# merging of cells

mergingSequences = getMergingSequences(densraster,lonmin,latmin,lonmax,latmax,ncells)

# check with shapefile
# -> OK
# 
# for(m in 1:4){
#   boxes = mergingSequences[[m]]
#   gridlines=list();id=1
#   for(i in 1:nrow(boxes)){
#     xmin=min(boxes[i,c(1,3,5,7)]);xmax=max(boxes[i,c(1,3,5,7)]);ymin=min(boxes[i,c(2,4,6,8)]);ymax=max(boxes[i,c(2,4,6,8)])
#     gridlines[[id]]=Lines(Line(cbind(c(xmin,xmax),c(ymin,ymin))),as.character(id));id=id+1
#     gridlines[[id]]=Lines(Line(cbind(c(xmin,xmax),c(ymax,ymax))),as.character(id));id=id+1
#     gridlines[[id]]=Lines(Line(cbind(c(xmin,xmin),c(ymin,ymax))),as.character(id));id=id+1
#     gridlines[[id]]=Lines(Line(cbind(c(xmax,xmax),c(ymin,ymax))),as.character(id));id=id+1
#   }
#   writeOGR(obj = SpatialLinesDataFrame(SpatialLines(LinesList = gridlines,proj4string = crs(densraster)),data.frame(ID=sapply(gridlines,function(x){x@ID})),match.ID = FALSE),
#                  dsn='testlight',layer = paste0('grid_merging_centre_',m),driver = 'ESRI Shapefile',overwrite_layer = TRUE
#   )
# }

# 
#system('./runtest.sh')


prevdb=global.destdb_prov
for(l in 1:length(mergingSequences)){
  currentdb=paste0('nw_simpl_',l)
  system(paste0('./setupDB.sh ',currentdb))
   show(paste0("merging : ",l))
   seq = mergingSequences[[l]]
#   #
   #currentGraph=list()
   #for(i in 1:nrow(seq)){
     res <- foreach(i=1:nrow(seq)) %dopar% {
       try({
     #show(i)
     source('nwSimplFunctions.R')
     localres = mergeLocalGraphs(seq[i,],xr=xr,yr=yr,dbname=prevdb)
     #if(length(localres$sg)>0){currentGraph=mergeGraphs(currentGraph,localres$sg)}
     exportGraph(localres$sg,dbname=currentdb)
       })
   }
   prevdb=currentdb
   #system('./runtest.sh')
   #exportGraph(currentGraph,dbname=global.destdb_simpl)
   #global.destdb_prov = global.destdb_simpl
 }
# 

# for(l in 1:length(mergingSequences)){
#  system(paste0('pgsql2shp -f testlight/centre_simpl_',l,' -p 5433 nwtest_simpl_',l,' links'))
# }

stopCluster(cl)

#show(res)
#show(length(which(unlist(res)>0)))

# ellapsed time
show(paste0("Ellapsed : ",(proc.time()[3]-startTime)))








