
# direct simplification

#
# assumes a full osmdb ; cuts it into coords bbox,
#   parallelized in a parfor loop
#

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))

source('nwSimplFunctions.R')

#densraster <- raster(paste0(Sys.getenv("CN_HOME"),"/Data/PopulationDensity/raw/density_wgs84.tif"))
densraster <- getRaster(paste0(Sys.getenv("CN_HOME"),"/Data/China/PopulationGrid_China2010/PopulationGrid_China2010.tif"),newresolution=100,reproject=T)
xr=xres(densraster);yr=yres(densraster)

latmin=extent(densraster)@ymin;latmax=extent(densraster)@ymax;
lonmin=extent(densraster)@xmin;lonmax=extent(densraster)@xmax

#latmin=46.34;latmax=48.94;lonmin=0.0;lonmax=3.2 # coordinates for db 'centre'
#latmin=49.4;latmax=50.25;lonmin=5.65;lonmax=6.6 # coordinates for db 'luxembourg'
#latmin=49.9;latmax=50.183488;lonmin=5.7300013;lonmax=6.53 # coordinates for db 'luxembourg'

ncells = 200

# get coordinates
coords <- getCoords(densraster,lonmin,latmin,lonmax,latmax,ncells)

tags=c("motorway","trunk","primary","secondary","tertiary","unclassified","residential")

# db config
#global.osmdb='europe';global.dbport=5433;global.dbuser="juste";global.dbhost=""
#global.osmdb='centre';global.dbport=5433;global.dbuser="Juste";global.dbhost="localhost"
global.dbport=5433;global.dbuser="juste"

# origin db
global.osmdb='china'
# destination bases
global.destdb_full='china_nw_full';global.destdb_prov='china_nw_prov';global.destdb_simpl='china_nw_simpl'

# reinit dbs
system(paste0('./setupDB.sh ',global.destdb_full))
system(paste0('./setupDB.sh ',global.destdb_prov))

library(doParallel)
cl <- makeCluster(20,outfile='log')
registerDoParallel(cl)

startTime = proc.time()[3]

##
# construction of local graphs
#  -- fills nw_full and nw_prov databases

res <- foreach(i=1:nrow(coords)) %dopar% {
  source('nwSimplFunctions.R')
  lonmin=coords[i,1];lonmax=coords[i,3];latmin=coords[i,4];latmax=coords[i,2]
  localGraph = constructLocalGraph(lonmin,latmin,lonmax,latmax,tags,xr,yr)
  exportGraph(localGraph$gg,dbname=global.destdb_full)
  exportGraph(localGraph$sg,dbname=global.destdb_prov)
}


##
# merging of cells

mergingSequences = getMergingSequences(densraster,lonmin,latmin,lonmax,latmax,ncells)


prevdb=global.destdb_prov
for(l in 1:length(mergingSequences)){
   currentdb=paste0('nw_simpl_',l)
   system(paste0('./setupDB.sh ',currentdb))
   show(paste0("merging : ",l))
   seq = mergingSequences[[l]]
   res <- foreach(i=1:nrow(seq)) %dopar% {
       try({
          source('nwSimplFunctions.R')
          localres = mergeLocalGraphs(seq[i,],xr=xr,yr=yr,dbname=prevdb)
          exportGraph(localres$sg,dbname=currentdb)
       })
   }
   prevdb=currentdb
 }

stopCluster(cl)

# ellapsed time
show(paste0("Ellapsed : ",(proc.time()[3]-startTime)))








