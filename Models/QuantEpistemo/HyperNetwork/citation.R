
# Citation Network Analysis

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/QuantEpistemo'))

library(dplyr)
library(igraph)

source('HyperNetwork/HyperNetwork/functions.R')

# raw network
#edges <- read.csv('HyperNetwork/data/EvolutiveUrbanTheory/EvUrbTh-cit2_links.csv',sep=";",header=F,colClasses = c('character','character'))
#edges <- read.csv('HyperNetwork/data/NetworkTerritories/cit2_links.csv',sep=";",header=F,colClasses = c('character','character'))
edges <- read.csv('HyperNetwork/data/UrbanGrowth/urbangrowth_depth2_links.csv',sep=";",header=F,colClasses = c('character','character'))


#nodesabstr <- as.tbl(read.csv('HyperNetwork/data/EvolutiveUrbanTheory/EvUrbTh-cit2-abstract.csv',sep=";",header=F,stringsAsFactors = F,colClasses = c(rep('character',5))))
#nodes <- as.tbl(read.csv('HyperNetwork/data/EvolutiveUrbanTheory/EvUrbTh-cit2.csv',sep=";",header=F,stringsAsFactors = F,colClasses = c('character','character','character')))
#nodes <- as.tbl(read.csv('HyperNetwork/data/NetworkTerritories/cit2.csv',sep=";",header=F,stringsAsFactors = F,colClasses = c('character','character','character')))
nodes <- as.tbl(read.csv('HyperNetwork/data/UrbanGrowth/urbangrowth_depth2.csv',sep=";",header=F,stringsAsFactors = F,colClasses = c('character','character','character')))


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

citation <- graph_from_data_frame(edges,vertices = nodes[,c(2,1,3)])#3:7)])

#plot.igraph(raw,layout=layout_with_fr(raw),vertex.label=NA,vertex.size=1)

#V(raw)$V1[components(raw)$membership==2]
# length(components(raw)$csize)

citation = induced_subgraph(citation,which(components(citation)$membership==1))
#V(raw)$primary = V(raw)$name%in%nodesprim$V2

#primary = induced_subgraph(raw,which(V(raw)$primary==TRUE))
#V(primary)$reduced_title = sapply(V(primary)$title,function(s){substr(s,1,20)})
#V(primary)$cut_title = sapply(V(primary)$title,function(s){paste0(substr(s,1,floor(nchar(s)/2)),'\n',substr(s,floor(nchar(s)/2)+1,nchar(s)))})
#V(primary)$authoryear = paste0(V(primary)$authors,V(primary)$year)

#V(raw)$primtitle = ifelse(V(raw)$primary,paste0(V(primary)$authors,V(primary)$year),"")
#V(raw)$reduced_primtitle = ifelse(V(raw)$primary,sapply(V(raw)$title,function(s){paste0(substr(s,1,25),'...')}),"")

V(citation)$reduced_title = sapply(V(citation)$title,function(s){paste0(substr(s,1,30),"...")})
V(citation)$reduced_title = ifelse(degree(citation)>50,V(citation)$reduced_title,rep("",vcount(citation)))
#V(raw)$reduced_title=rep("",vcount(raw))


citationcore = induced_subgraph(citation,which(degree(citation)>1))

#V(rawcore)$title = rep("",vcount(rawcore))

#write_graph(raw,file='EvolutiveUrbanTheory/data/citation.gml',format = 'gml')
#write_graph(primary,file='EvolutiveUrbanTheory/data/primary.gml',format = 'gml')

#write_graph(rawcore,file='EvolutiveUrbanTheory/data/primarycore.gml',format = 'gml')
write_graph(citationcore,file='HyperNetwork/data/UrbanGrowth/rawcore.gml',format = 'gml')

ecount(citationcore)/(vcount(citationcore)*(vcount(citationcore)-1))

##
# analysis of raw

mean(degree(citation))
mean(degree(citation,mode = 'in'))
mean(degree(citationcore,mode = 'in'))


##
#  analysis of rawcore

#A = as.matrix(as_adjacency_matrix(citationcore,sparse = T))
A=as_adjacency_matrix(citationcore,sparse = T)
M = A+t(A)
undirected_rawcore = graph_from_adjacency_matrix(M,mode="undirected")

# communities
com = cluster_louvain(undirected_rawcore)



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


######
# content of communities
#

d=degree(citationcore,mode='in')
for(c in unique(com$membership)){
  show(paste0("Community ",c, " ; corpus prop ",length(which(com$membership==c))/vcount(undirected_rawcore)))
  #show(paste0("Size ",length(which(com$membership==c))))
  currentd=d[com$membership==c];dth=sort(currentd,decreasing = T)[10]
  show(data.frame(titles=V(citationcore)$title[com$membership==c&d>dth],degree=d[com$membership==c&d>dth]))
  #show(V(rawcore)$title[com$membership==c])
}

# -> OK deteministic communities ; no need to save. (multi-level this louvain, not random ?)

# nom des communaut??s de citation
#citcomnames=list('7'='LUTI','10'='Geography','3'='Infra Planning','12'='Networks','11'='TOD','8'='Accessibility')
citcomnames=list('22'='Urban Ecology','8'='Urban Sociology','16'='Housing Market','5'='Spatial Statistics',
                 '19'='Economic Geography','23'='Criminology','1'='Cellular Automata','10'='Urban Simulation',
                 '9'='Development','2'='Ecology','20'='Mobility','6'='LUTI','4'='Networks','18'='Economy of Information',
                 )

#V(citationcore)$citclass = unlist(sapply(as.character(com$membership),function(n){ifelse(n%in%names(citcomnames),unlist(citcomnames[n]),'NA')}))
V(citationcore)$citmemb = com$membership

save(citation,citationcore,citcomnames,com,undirected_rawcore,file='HyperNetwork/HyperNetwork/processed/citation.RData')
# 

## these communities are on the core ; for semantic shall we extend ?
#  -> compare with full communities

#A = as.matrix(as_adjacency_matrix(citation))
#M = A+t(A)
#undirected_citation = graph_from_adjacency_matrix(M,mode="undirected")

# communities
#com = cluster_louvain(undirected_citation)

# -> 50 coms, mod 0.83 - seems quite ???







