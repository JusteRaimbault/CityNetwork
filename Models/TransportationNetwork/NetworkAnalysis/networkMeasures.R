

gamma<-function(g){
  return(list(
    vcount=vcount(g),
    ecount=ecount(g),
    gamma = 2*ecount(g)/(vcount(g)*(vcount(g)-1)),
    meanDegree = mean(degree(g)),
    mu = ecount(g) - vcount(g) + 1,
    alpha = (ecount(g) - vcount(g) + 1)/(2*vcount(g)-5)
  )
  )
}


#'
#'
normalizedBetweenness<-function(g,subsample=0,cutoff=0,ego.order=0){
  if(subsample>0){
    m=as_adjacency_matrix(g)
    inds = sample.int(n = nrow(m),size = floor(subsample*nrow(m)),replace = F)
    g=graph_from_adjacency_matrix(m[inds,inds])
  }
  show(paste0('computing betwenness for graph of size ',vcount(g),' with cutoff ',cutoff))
  if(cutoff==0){
    if(ego.order==0){
      bw = edge_betweenness(g)*2/(vcount(g)*(vcount(g)-1))
    }else{
      show('bootstrapping betwenness')
      # TODO
    }
  }else{
    bw = estimate_edge_betweenness(g,cutoff=cutoff)*2/(vcount(g)*(vcount(g)-1))
    # normalization should be a bit different with cutoff ?
    # let approximate
  }
  y=sort(log(bw),decreasing=T)
  reg = lm(data=data.frame(x=log(1:length(which(is.finite(y)))),y=y[is.finite(y)]),formula = y~x)
  return(
    list(
      #bw=bw,
      meanBetweenness = mean(bw),
      stdBetweenness = sd(bw),
      alphaBetweenness = reg$coefficients[2]
    )
  )
}


#'
#' @description includes closeness, efficiency, and diameter
#'      note : distances are not weighted for comparison purposes between synthetic and real
#'      , meaning that we consider only topological distance.
shortestPathMeasures<-function(g){
  distmat = distances(g)
  distmatfinite = distmat
  distmatfinite[!is.finite(distmatfinite)]=0
  # get diameter
  diameter = max(distmatfinite)
  #show(diameter)
  # get closeness
  closenesses = (vcount(g)-1) / rowSums(distmatfinite[rowSums(distmatfinite)>0,])
  #show(closenesses)
  y=sort(log(closenesses/diameter),decreasing=T)
  reg = lm(data=data.frame(x=log(1:length(which(is.finite(y)))),y=y[is.finite(y)]),formula = y~x)
  # compute efficiency
  diag(distmat)<-Inf
  efficiency=mean(1/distmat)
  return(list(
    diameter=diameter,
    efficiency=efficiency,
    meanCloseness=mean(closenesses)/diameter,
    alphaCloseness=reg$coefficients[2]
  ))
}

#'
#'
clustCoef<-function(g){
  return(list(transitivity=transitivity(g)))
}

#'
#'
louvainModularity<-function(g){
  com=cluster_louvain(g)
  return(list(
    modularity = max(com$modularity)
  ))
}



