
#setwd(paste0(Sys.getenv('CS_HOME'),'/Cybergeo/cybergeo20/HyperNetwork/Models/Analysis'))
library(dplyr)
library(igraph)
#source('networkConstruction.R')

#db='relevant_full_50000_eth50_nonfiltdico'
#g = filterGraph(g,'data/filter.csv') # filtering
# freqmax = 10000 ; freqminvals = c(50,100) ; kmaxvals = c(600,1000) ; ethvals = c(150,200,240)

#'
#' @title Compute themes probablitites
#' @name computeThemProbablities
#' @description Compute probas for given parameter range
computeThemProbablities <- function(db,filters,freqmaxvals,freqminvals,kmaxvals,ethvals,ncores=12){
  
  load(paste0('processed/',db,'.RData'))
  g=res$g;
  
  for(filt in filters){
    g = filterGraph(g,filt)
  }
  
  #clust = clusters(g);cmax = which(clust$csize==max(clust$csize))
  #ggiant = induced.subgraph(g,which(clust$membership==cmax))
  
  kmin = 0
  
  params=data.frame()
  for(freqmax in freqmaxvals){
    for(freqmin in freqminvals){
      for(kmax in kmaxvals){
        for(edge_th in ethvals){
          params=rbind(params,c(freqmin,kmax,edge_th))
        }
      }
    }
  }
  
  
  library(doParallel)
  cl <- makeCluster(ncores)
  registerDoParallel(cl)
  
  res <- foreach(i=1:nrow(params)) %dopar% {
    source('networkConstruction.R')
    sub = extractSubGraphCommunities(g,kmin,params[i,2],params[i,1],freqmax,params[i,3])
    probas = computeThemProbas(sub$gg,sub$com,res$keyword_dico)
    save(sub,probas,file=paste0('probas/',db,'_kmin',kmin,'_kmax',params[i,2],'_freqmin',params[i,1],'_freqmax',freqmax,'_eth',params[i,3],'.RData'))
  }
  
  stopCluster(cl)
  
}


#################
#################

#dbparams = 'relevant_full_50000_eth50_nonfiltdico_kmin0_kmax1000_freqmin100_freqmax10000_eth150'
#load(paste0('probas/',dbparams,'.RData'))
#them_probas = probas









