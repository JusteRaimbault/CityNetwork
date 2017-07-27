
# sensitivity to threshold parameters

library(dplyr)
library(igraph)
source('networkConstruction.R')


#'
#' @title Network sensitivity analysis
#' @name networkSensitivity
#' @description Network measures for filtering parameter ranges
#'
networkSensitivity <- function(db,filters,freqmaxvals,freqminvals,kmaxvals,ethvals,outputfile){
  
  
  load(paste0('processed/',db,'.RData'))
  g=res$g;
  keyword_dico=res$keyword_dico
  rm(res);gc()
  
  for(filt in filters){
    g = filterGraph(g,filt)
  }
  
  # Q : work on giant component ?
  # 
  clust = clusters(g);cmax = which(clust$csize==max(clust$csize))
  ggiant = simplify(induced.subgraph(g,which(clust$membership==cmax)),edge.attr.comb = list(weight='mean'))
  
  kmin = 0
  
  modularities = c();
  comnumber=c();
  dmax=c();
  eth=c();
  csizes=c();
  gsizes=c();
  gdensity=c();
  cbalance=c();
  freqsmin=c();freqsmax=c()
  for(freqmax in freqmaxvals){
    for(freqmin in freqminvals){
      for(kmax in kmaxvals){
        for(edge_th in ethvals){
          show(paste0('kmax : ',kmax,' e_th : ',edge_th,' ; freqmin : ',freqmin,' ; freqmax : ',freqmax))
          dd = V(ggiant)$docfrequency
          d = degree(ggiant)
          gg=induced_subgraph(ggiant,which(d>kmin&d<kmax&dd>freqmin&dd<freqmax))
          gg=subgraph.edges(gg,which(E(gg)$weight>edge_th))
          clust = clusters(gg);cmax = which(clust$csize==max(clust$csize))
          gg = induced.subgraph(gg,which(clust$membership==cmax))
          com = cluster_louvain(gg)
          # measures
          gsizes=append(gsizes,length(V(gg)));
          gdensity=append(gdensity,2*length(E(gg))/(length(V(gg))*(length(V(gg))-1)))
          csizes=append(csizes,length(clust$csize))
          modularities = append(modularities,modularity(com))
          comnumber=append(comnumber,length(communities(com)))
          cbalance=append(cbalance,sum((sizes(com)/length(V(gg)))^2))
          dmax=append(dmax,kmax);eth=append(eth,edge_th)
          freqsmin=append(freqsmin,freqmin);freqsmax=append(freqsmax,freqmax)
        }
      }
    }
  }
  
  d = data.frame(degree_max=dmax,edge_th=eth,vertices=gsizes,components=csizes,modularity=modularities,communities=comnumber,density=gdensity,comunitiesbalance=cbalance,freqmin=freqsmin,freqmax=freqsmax)
  names(d)[ncol(d)-2]="balance"
  
  save(d,file=outputfile)
  
}


