
# direct simplification

#
# assumes a full osmdb ; cuts it into coords bbox,
#   parallelized in a parfor loop
#

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))

source('nwSimplFunctions.R')

densraster <- raster(paste0(Sys.getenv("CN_HOME"),"/Data/PopulationDensity/raw/density_wgs84.tif"))
#latmin=extent(densraster)@ymin;latmax=extent(densraster)@ymax;
#lonmin=extent(densraster)@xmin;lonmax=extent(densraster)@xmax
latmin=46.34;latmax=48.94;lonmin=0.0;lonmax=3.2

ncells = 500

# get coordinates
coords <- getCoords(densraster,lonmin,latmin,lonmax,latmax,ncells)

tags=c("motorway","trunk","primary","secondary","tertiary","unclassified","residential")
osmdb='centre';dbport=5433

#library(doParallel)
#cl <- makeCluster(10)
#registerDoParallel(cl)

#startTime = proc.time()[3]

##
# construction of local graphs

#foreach(i=1:nrow(coords)) %dopar% {
for(i in c(1,2)){#nrow(coords)){
  source('nwSimplFunctions.R')
  lonmin=coords[i,1];lonmax=coords[i,3];latmin=coords[i,4];latmax=coords[i,2]
  localGraph = constructLocalGraph(lonmin,latmin,lonmax,latmax,tags)
  exportGraph(localGraph$gg,dbname="nwtest_full")
  exportGraph(localGraph$sg,dbname="nwtest_prov")
}

##
# merging of cells

#mergingSequences = getMergingSequences(densraster,lonmin,latmin,lonmax,latmax,ncells)

#for(l in 1:length(mergingSequences)){
#  show(paste0("merging : ",l))
#  seq = mergingSequences[[l]]
#  res <- foreach(i=1:length(seq)) %dopar% {
#  #for(i in 1:length(seq)){
#    source('nwSimplFunctions.R')
#    locres = mergeLocalGraphs(seq[i,])
#    exportGraph(localres$sg,dbname="nwtest_simpl")
#  }
#}


#stopCluster(cl)

#show(res)
#show(length(which(unlist(res)>0)))








