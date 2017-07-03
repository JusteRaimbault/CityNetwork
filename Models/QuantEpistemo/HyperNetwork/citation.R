
# Citation Network Analysis

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/QuantEpistemo'))

library(dplyr)
library(igraph)


# raw network
#edges <- read.csv('HyperNetwork/data/EvolutiveUrbanTheory/EvUrbTh-cit2_links.csv',sep=";",header=F,colClasses = c('character','character'))
edges <- read.csv('HyperNetwork/data/NetworkTerritories/cit2_links.csv',sep=";",header=F,colClasses = c('character','character'))

#nodesabstr <- as.tbl(read.csv('HyperNetwork/data/EvolutiveUrbanTheory/EvUrbTh-cit2-abstract.csv',sep=";",header=F,stringsAsFactors = F,colClasses = c(rep('character',5))))
#nodes <- as.tbl(read.csv('HyperNetwork/data/EvolutiveUrbanTheory/EvUrbTh-cit2.csv',sep=";",header=F,stringsAsFactors = F,colClasses = c('character','character','character')))
nodes <- as.tbl(read.csv('HyperNetwork/data/NetworkTerritories/cit2.csv',sep=";",header=F,stringsAsFactors = F,colClasses = c('character','character','character')))

#nodesprim <-read.csv('HyperNetwork/data/EvolutiveUrbanTheory/EvUrbTh-cit1-grepPumainSandersBretagnolle.csv',sep=";",header=F,stringsAsFactors = F,colClasses = c('character','character','character'))
# add initial primary
#nodesprimnoabstr <- read.csv('HyperNetwork/data/EvUrbTh-cit1.csv',sep=";",header=F,stringsAsFactors = F,colClasses = c('character','character','character'))


# sapply(nodesprim$V1,nchar)
# length(unique(c(edges$V1,edges$V2)))
# nodes$V2[!nodes$V2%in%elabels]
# elabels[!elabels%in%nodes$V2]
# dim(left_join(nodes,nodesabstr,by=c("V2"="V2")))
#nodes=left_join(nodes,nodesabstr,by=c("V2"="V2"))
#nodes=nodes[,c(1:3,6:7)]

#names(nodes)<-c("title","id","year","abstract","authors")
names(nodes)<-c("title","id","year")

elabels = unique(c(edges$V1,edges$V2))
empty=rep("",length(which(!elabels%in%nodes$id)))
nodes=rbind(nodes,data.frame(title=empty,id=elabels[!elabels%in%nodes$id],year=empty))#,abstract=empty,authors=empty))

raw <- graph_from_data_frame(edges,vertices = nodes[,c(2,1,3)])#3:7)])

#plot.igraph(raw,layout=layout_with_fr(raw),vertex.label=NA,vertex.size=1)

#V(raw)$V1[components(raw)$membership==2]
# length(components(raw)$csize)

raw = induced_subgraph(raw,which(components(raw)$membership==1))
#V(raw)$primary = V(raw)$name%in%nodesprim$V2

#primary = induced_subgraph(raw,which(V(raw)$primary==TRUE))
#V(primary)$reduced_title = sapply(V(primary)$title,function(s){substr(s,1,20)})
#V(primary)$cut_title = sapply(V(primary)$title,function(s){paste0(substr(s,1,floor(nchar(s)/2)),'\n',substr(s,floor(nchar(s)/2)+1,nchar(s)))})
#V(primary)$authoryear = paste0(V(primary)$authors,V(primary)$year)

#V(raw)$primtitle = ifelse(V(raw)$primary,paste0(V(primary)$authors,V(primary)$year),"")
#V(raw)$reduced_primtitle = ifelse(V(raw)$primary,sapply(V(raw)$title,function(s){paste0(substr(s,1,25),'...')}),"")

V(raw)$reduced_title = sapply(V(raw)$title,function(s){paste0(substr(s,1,30),"...")})
V(raw)$reduced_title = ifelse(degree(raw)>50,V(raw)$reduced_title,rep("",vcount(raw)))
#V(raw)$reduced_title=rep("",vcount(raw))

rawcore = induced_subgraph(raw,which(degree(raw)>1))

V(rawcore)$title = rep("",vcount(rawcore))

#write_graph(raw,file='EvolutiveUrbanTheory/data/citation.gml',format = 'gml')
#write_graph(primary,file='EvolutiveUrbanTheory/data/primary.gml',format = 'gml')

#write_graph(rawcore,file='EvolutiveUrbanTheory/data/primarycore.gml',format = 'gml')
write_graph(rawcore,file='HyperNetwork/data/NetworkTerritories/rawcore.gml',format = 'gml')

ecount(rawcore)/(vcount(rawcore)*(vcount(rawcore)-1))

##
#  analysis of rawcore

A = as.matrix(as_adjacency_matrix(rawcore))
M = A+t(A)
undirected_rawcore = graph_from_adjacency_matrix(M,mode="undirected")

com = cluster_louvain(undirected_rawcore)

directedmodularity<-function(membership,adjacency){
  m=sum(adjacency)
  kout=rowSums(adjacency);kin=colSums(adjacency)
  res = 0;k=length(unique(membership))
  for(c in unique(membership)){
    #if(c%%100==0){show(c/k)}
    inds=which(membership==c)
    res = res + sum(adjacency[inds,inds]) - sum(kin[inds])*sum(kout[inds])/m 
    gc()
  }
  return(res/m)
}

directedmodularity(com$membership,A)

# randomise links
nreps = 100
mods = c()
for(i in 1:nreps){
  show(i)
  mods=append(mods,directedmodularity(com$membership,A[sample.int(nrow(A),nrow(A),replace = F),sample.int(ncol(A),ncol(A),replace = F)]))
}

show(paste0(mean(mods)," +- ",sd(mods)))
# -> 260 sds, ultra significant

# content of communities
for(c in unique(com$membership)){
  show(c)
  show(V(rawcore)$title[com$membership==c&V(rawcore)$primary==T])
}







