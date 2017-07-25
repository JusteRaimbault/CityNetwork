



# export thematics for Clem mappping



#'
#'
exportData <- function(nkws,eth_0,eth,kmin,kmax,freqmin,freqmax,eth){
  db=paste0('relevant_full_',nkws,'_eth',eth_0,'_nonfiltdico')
  dbparams = paste0('relevant_full_',nkws,'_eth',eth_0,'_nonfiltdico_kmin',kmin,'_kmax',kmax,'_freqmin',freqmin,'_freqmax',freqmax,'_eth',eth)
  
  load(paste0('probas/',dbparams,'.RData'))
  load(paste0('processed/',db,'.RData'))
  keyword_dico=res$keyword_dico;g=res$g;rm(res);gc()
  them_probas = probas
  
  # define comunities names
  # com
  thematics = communities(sub$com)

  # define names by hand
  themnames = as.character(read.csv(file=paste0('export/comunitiesnames/',dbparams,'.csv'),header=FALSE,stringsAsFactors = FALSE)[,1])
  names(thematics)<-themnames
  
  # select existing thematics
  export_probas = them_probas[,!is.na(names(thematics))]
  colnames(export_probas) = names(thematics)[!is.na(names(thematics))]
  themnames=colnames(export_probas)[2:ncol(export_probas)]
  
  
  
  # construct kws df
  ckws=c();cth=c();cdocfreq=c()
  for(i in 1:length(thematics)){
    if(!is.na(names(thematics)[i])){
      for(kw in thematics[[i]]){
        show(c(kw,names(thematics)[i]))
        ckws=append(ckws,kw)
        cth=append(cth,names(thematics)[i])
        cdocfreq=append(cdocfreq,V(sub$gg)[kw]$docfreq)
      }
    }
  }
  
  kwdf = data.frame(ckws,cth)
  kwthemdico = cth;names(kwthemdico)=ckws
  kwfreqs = cdocfreq;names(kwfreqs)=ckws
  
  #kws = as.tbl(kwdf)
  #kws %>% group_by(X2) %>% summarise(l=length(X1)) %>% arrange(l)
  #data.frame(kws[kws[,2]=='crime',])
  
  # load them probas
  #  -> precomputed in semthem_probas
  
  
  
  # need iscyb and cybindexes
  # -> load from consolidated db
  #export_probas = cbind(data.frame(export_probas),as.character(names(keyword_dico)))
  #colnames(export_probas)[13]="ID"
  load(paste0(Sys.getenv('CS_HOME'),'/Cybergeo/cybergeo20/HyperNetwork/Data/nw/citationNetwork.RData'))
  cybergeo <- read.csv(paste0(Sys.getenv('CS_HOME'),'/Cybergeo/cybergeo20/Data/raw/cybergeo.csv'),colClasses = c('integer',rep('character',25)))
  cyb = getCybindexes(them_probas,cybnames,cybergeo,keyword_dico)
  cybid=cyb$cybid;iscyb=cyb$iscyb
  export_probas = cbind(cybid,data.frame(export_probas))
  names(export_probas)[1] = "CYBERGEOID"
  
  citadjacency = get.adjacency(gcitation,sparse=TRUE)[names(keyword_dico),names(keyword_dico)]
  #rm(gcitation);gc()
  
  #cybprobas = as.tbl(export_probas[export_probas$CYBERGEOID>0,])
  #cybprobas[cybprobas$crime>0.1,]
  #intersect(keyword_dico[[cybergeo$SCHID[cybergeo$id==4994]]],thematics[['cognitive sciences']])
  
  #res = left_join(as.tbl(export_probas),as.tbl(cybergeo),by=c("ID","SCHID"))
  # export into dbparams
  # exdir=paste0('export/',dbparams)
  # dir.create(exdir)
  # 
  # write.table(export_probas,col.names = TRUE,row.names = FALSE,file = paste0(exdir,'/docprobas.csv'),sep=",")
  # write.table(kwdf,col.names = FALSE,row.names = FALSE,file = paste0(exdir,'/thematics.csv'),sep=",")
  # 
  # # export subgraph (for viz)
  keptvertices = sapply(V(sub$gg)$name,function(s){s%in%kwdf[,1]})
  gg=induced_subgraph(sub$gg,keptvertices)
  ind=1:nrow(kwdf);names(ind)=as.character(kwdf[,1]);V(gg)$community = as.character(kwdf[,2])[ind[V(gg)$name]]
  # gg=filterGraph(gg,'export/addfilter.csv')
  # E(gg)$weight = log(E(gg)$weight)
  # write.graph(gg,file = paste0(exdir,'/graph1.gml'),format = "gml")
  # 
  
  
}


