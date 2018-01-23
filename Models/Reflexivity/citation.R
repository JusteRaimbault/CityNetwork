
# Citation Network Analysis

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/Reflexivity'))

library(dplyr)
library(igraph)

source(paste0(Sys.getenv('CN_HOME'),'/Models/QuantEpistemo/HyperNetwork/HyperNetwork/functions.R'))

# raw network
edges <- read.csv('data/CityNetwork_20171127_links.csv',sep=";",header=F,colClasses = c('character','character'))
nodes <- as.tbl(read.csv('data/CityNetwork_20171127.csv',sep=";",header=F,stringsAsFactors = F,colClasses = c('character','character','character')))

#nodesabstract <-read.csv('data/abstracts_ids.csv',colClasses = c('character'))

names(nodes)<-c("title","id","year")
nodes=nodes[nchar(nodes$id)>0,]

#intersect(nodesabstract$X8635210426419881284,nodes$id)
mongoids <-read.csv('data/mongoids.csv',colClasses = c('character'))
#intersect(mongoids$id,nodes$id)
#intersect(nodesabstract$X8635210426419881284,mongoids$id)
#nwconstructids<-read.csv('data/nwconstructids.csv',colClasses = c('character','character'))
#intersect(nwconstructids$id,mongoids$id)

elabels = unique(c(edges$V1,edges$V2))
empty=rep("",length(which(!elabels%in%nodes$id)))
nodes=rbind(nodes,data.frame(title=empty,id=elabels[!elabels%in%nodes$id],year=empty))#,abstract=empty,authors=empty))

citation <- graph_from_data_frame(edges,vertices = nodes[,c(2,1,3)])#3:7)])
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
write_graph(citationcore,file='data/rawcore.gml',format = 'gml')

ecount(citationcore)/(vcount(citationcore)*(vcount(citationcore)-1))

# comparison values : from [Batagelj, 2003]
vref = c(40,223,396,1059,1059,3084,3244,4470,6752,8843,8851)#,3774768)
eref = c(60,657,1988,4922,4929,10416,31950,12731,54253,41609,25751)#,16522438)
summary(eref / (vref*(vref-1)))

##
# analysis of raw

mean(degree(citation))
mean(degree(citation,mode = 'in'))
mean(degree(citationcore,mode = 'in'))


##
#  analysis of rawcore

set.seed(0)

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
  if(sizes(com)[c] > 10){
    show(paste0("Community ",c, " ; corpus prop ",length(which(com$membership==c))/vcount(undirected_rawcore)))
    #show(paste0("Size ",length(which(com$membership==c))))
    currentd=d[com$membership==c];dth=sort(currentd,decreasing = T)[10]
    show(data.frame(titles=V(citationcore)$title[com$membership==c&d>dth],degree=d[com$membership==c&d>dth]))
    #show(V(rawcore)$title[com$membership==c])
  }
}

# -> OK deteministic communities ; no need to save. (multi-level this louvain, not random ?)

# nom des communautes de citation
citcomnames=list('28'='Chaos','64'='Economic Geography','62'='Urban Systems','67'='ABM',
                 '68'='Datamining','49'='Networks','47'='Spatial Statistics',
                 '34'='Fractals','37'='Power Laws','52'='Evolutionnary Economic Geography',
                 '21'='Quantitative Epistemology','23'='Spatial Urban Growth Models',
                 '60'='Complexity','66'='LUTI','50'='Physics of Cities',
                 '14'='Spatio-temporal data','40'='Biological Networks',
                 '63'='Space Syntax/Procedural modeling','51'='VGI'
                 )

#V(citationcore)$citclass = unlist(sapply(as.character(com$membership),function(n){ifelse(n%in%names(citcomnames),unlist(citcomnames[n]),'NA')}))
V(citationcore)$citmemb = com$membership

save(citation,citationcore,citcomnames,com,undirected_rawcore,file='processed/citation.RData')
# load('processed/citation.RData')

## these communities are on the core ; for semantic shall we extend ?
#  -> compare with full communities

#A = as.matrix(as_adjacency_matrix(citation))
#M = A+t(A)
#undirected_citation = graph_from_adjacency_matrix(M,mode="undirected")

# communities
#com = cluster_louvain(undirected_citation)

# -> 50 coms, mod 0.83 - seems quite ???







