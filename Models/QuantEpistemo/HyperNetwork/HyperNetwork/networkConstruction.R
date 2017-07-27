
#  functions for network construction and export

library(RMongo)
library(igraph)
library(dplyr)


#'
#' @name getCybindexes
#' @description Gets cybergeo indexes from consolidated data and citation network
getCybindexes<-function(them_probas,cybnames,cybergeo,keyword_dico){
  cybindexes = c();cybresnames = c();iscyb=rep(FALSE,nrow(them_probas));cybid = rep(0,nrow(them_probas))
  for(cyb in cybnames){
    #show(cyb)
    indexes = which(names(keyword_dico)==cyb);
    id=cybergeo$id[cybergeo$SCHID==cyb]
    if(length(indexes)>0){
      cybindexes=append(cybindexes,indexes[1]);
      cybresnames=append(cybresnames,cyb)
      iscyb[indexes[1]]=TRUE
      cybid[indexes[1]]=id[1]
    }
  }
  return(list(cybid=cybid,iscyb=iscyb,cybindexes=cybindexes,cybresnames=cybresnames))
}




#'
#' @title Community Extraction
#' @name extractSubGraphCommunities
#' @description Filter a graph on degree (kmin,kmax), document frequency (freqmin,freqmax) and co-occurence (edge_th)
#'  and computes optimal communities
#'  @param ggiant igraph; graph
#'  @param kmin ; minimal filtering degree
#'  @param kmax ; maximal filtering degree
#'  @param freqmin ; minimal filtering frequency
#'  @param freqmax ; maximal filtering frequency
#'  @param edge_th ; edge weight threshold
#'  
extractSubGraphCommunities<-function(g,kmin,kmax,freqmin,freqmax,edge_th){
  clust = clusters(g);cmax = which(clust$csize==max(clust$csize))
  ggiant = simplify(induced.subgraph(g,which(clust$membership==cmax)),edge.attr.comb = list(weight='mean'))
  dd = V(ggiant)$docfrequency
  d = degree(ggiant)
  gg=induced_subgraph(ggiant,which(d>kmin&d<kmax&dd>freqmin&dd<freqmax))
  gg=subgraph.edges(gg,which(E(gg)$weight>edge_th))
  clust = clusters(gg);cmax = which(clust$csize==max(clust$csize))
  gg = induced.subgraph(gg,which(clust$membership==cmax))
  com = cluster_louvain(gg)
  return(list(gg=gg,com=com))
}



#'
#' @description Summary of a subgraph
summarySubGraphCommunities<-function(sub){
   gg=sub$gg;com=sub$com
   show(paste0('Vertices : ',length(V(gg))))
   show(paste0('Communities : ',length(sizes(com))))
   show(paste0('Modularity : ',modularity(com)))
   show(paste0('Balance : ',sum((sizes(com)/length(V(gg)))^2)))
   show(sizes(com))
}



#'
#'  @name computeThemProbas
#'  @description Compute thematic probability matrix
computeThemProbas<-function(gg,com,keyword_dico){
  # construct kw -> thematic dico
  thematics = list()
  for(i in 1:length(V(gg))){
    thematics[[V(gg)$name[i]]]=com$membership[i]
  }
  
  them_probas = matrix(0,length(names(keyword_dico)),length(unique(com$membership)))
  for(i in 1:length(names(keyword_dico))){
    if(i%%100==0){show(i)}
    kwcount=0
    for(kw in keyword_dico[[names(keyword_dico)[i]]]){if(kw %in% names(thematics)){
      j=thematics[[kw]]
      them_probas[i,j]=them_probas[i,j]+1;kwcount=kwcount+1
    }}
    if(kwcount>0){them_probas[i,]=them_probas[i,]/kwcount}
  }
  return(them_probas)
}



#'
#' @title Semantic Network construction
#' @name constructSemanticNetwork
#' @description Construct semantic coocurrence graph directly from nw table in mongo. Kw dico is reconstructed here (not that efficient in R)
#' 
constructSemanticNetwork<-function(relevantcollection,kwcollection,nwcollection,edge_th,target,mongo){
  #relevantcollection='relevant_10000'
  relevant <- dbGetQuery(mongo,relevantcollection,'{}',skip=0,limit = 1000000)
  #kwcollection='keywords'
  # has to fix limit ? ok reasonable corpuses
  dicoraw <- dbGetQueryForKeys(mongo,kwcollection,'{}','{"id":1,"keywords":1}',skip=0,limit=1000000)
  # has to do some string splitting
  dico=sapply(dicoraw$keywords,function(s){strsplit(trimws(gsub("[",'',gsub("]",'',gsub('\"','',s),fixed=T),fixed=T)),' , ')})
  names(dico)=as.character(dicoraw$id)
  
  relevant = relevant[,c('keyword','cumtermhood','docfrequency','tidf')]
  #relevant = data.frame(keyword=sapply(relevant,function(d){d$keyword}),
  #                      cumtermhood=sapply(relevant,function(d){d$cumtermhood}),
  #                      docfreq=sapply(relevant,function(d){d$docfrequency}),
  #                      tidf=sapply(relevant,function(d){d$tidf})
  #                      )
  
  srel = as.tbl(relevant)
  srel$keyword = as.character(srel$keyword)
  
  rel = list()
  for(i in 1:length(srel$keyword)){rel[[srel$keyword[i]]]=i}
  
  # construct kw dico : ID -> keywords
  keyword_dico = dico
  #keyword_dico = list()
  #for(i in 1:length(dico)){
  #  if(i%%100==0){show(paste0('dico : ',i/length(dico),'%'))}
  #  #kws = unique(dico[[i]]$keywords)
  #  kws = dico[[i]]$keywords
  #  #show(kws)
  #  if(length(kws)>0){
  #    #kws = kws[sapply(kws,function(w){w %in% srel$keyword})]
  #    keyword_dico[[dico[[i]]$id]]=kws
  #  }
  #}
  
  # construct now edge dataframe
  #edges <- mongo.find.all(mongo,nwcollection)
  # nwcollection = 'network_10000_eth5'
  show('Getting edges...')
  edges <- dbGetQueryForKeys(mongo,nwcollection,paste0('{"weight":{$gt:',edge_th-1,'}}'),'{"edge":1,"weight":1}',skip=0,limit=1000000000)
  
  #e1=c();e2=c();weights=c()
  #for(i in 1:nrow(edges)){
  #  if(i%%1000==0){show(paste0('edges : ',i/length(edges),'%'))}
  #  w=edges$weight[i]
  #  if(w>=edge_th){ # should be always verified
  #     e = strsplit(edges$edge[i],";")[[1]]
  #     if(e[1]!=e[2]){# avoid self loops, weight info is already contained in doc frequency of nodes
  #       e1=append(e1,e[1]);e2=append(e2,e[2]);weights=append(weights,w)
  #     }
  #  }
  #}
  split=strsplit(edges$edge,';')
  e1=sapply(split,function(l){l[1]});e2=sapply(split,function(l){l[2]})
  weights=edges$weight
  edgesv=unique(c(e1,e2))
  missingvertices = edgesv[!(edgesv%in%relevant$keyword)]
  show(paste0('missing vertices : ',length(missingvertices)))
  if(length(missingvertices)>0){relevant=rbind(relevant,data.frame(keyword=missingvertices,cumtermhood=rep(0,length(missingvertices)),docfreq=rep(0,length(missingvertices)),tidf=rep(0,length(missingvertices))))}
  
  res = list()
  res$g = graph_from_data_frame(data.frame(from=e1,to=e2,weight=weights),directed=FALSE,vertices = relevant)
  res$keyword_dico=keyword_dico
  
  show(res$g)
  
  save(res,file=paste0(target,'.RData'))
  
}




# DEPRECATED
#importDicoCsv<-function(kwFile){
#  res=list()
#  relevant = read.table(paste0("../Semantic/res/cybergeo/kw_",kwFile,".csv"),header=FALSE,sep=";",stringsAsFactors = FALSE)
#  colnames(relevant)=c("keyword","cumtermhood")
#  dico = scan(paste0("../Semantic/res/cybergeo/relevantDico_kwLimit",kwFile,".csv"),what="character",sep="\n")
#  relevant$keyword=sapply(relevant$keyword,FUN=enc2utf8)
#  res$relevant=relevant
#  res$dico=dico
#  return(res)
#}



#'
#' @title Graph Filtering
#' @name filterGraph
#' @description filter nodes : grep -v -f file for nodes names
filterGraph<-function(graph,file){
  words<-unlist(read.csv(file,stringsAsFactors=FALSE,header=FALSE))
  g=graph
  for(w in 1:length(words)){
    g=induced.subgraph(g,which(V(g)$name!=words[w]))
  }
  return(g)
}



