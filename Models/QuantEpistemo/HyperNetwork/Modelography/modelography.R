
# corpus construction for modelography
#  (following interdisc)

library(igraph)
library(dplyr)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/QuantEpistemo/HyperNetwork/Modelography'))


load(paste0(Sys.getenv('CN_HOME'),'/Models/QuantEpistemo/HyperNetwork/HyperNetwork/processed/citation.RData'))


#######
## KW corpus

# cit nw is subcit

# rq : sem compo of cit coms are rather balanced
#  -> use directly semantic communities, select kws on degree, a given proportion of each class

kws = data.frame()
for(k in unique(coms$membership)){
  show(paste0('Com ',k,', size : ',length(which(coms$membership==k)),' , weight docs : ',100*colSums(probas)[k]/sum(probas)))
  vertices=(coms$membership==k)
  currentnames=V(gg)$name[vertices];currentdegree=degree(gg)[vertices]
  #degth = sort(currentdegree,decreasing = T)[20]
  degth = quantile(currentdegree,0.8)
  kws = rbind(kws,data.frame(name=currentnames[currentdegree>=degth],degree=currentdegree[currentdegree>=degth]))
}


# by weight ?
kwedges = E(gg)[E(gg)$weight>quantile(E(gg)$weight,0.95)&head_of(gg,E(gg))$name%in%as.character(kws$name)&tail_of(gg,E(gg))$name%in%as.character(kws$name)]

write.csv(c(unique(c(head_of(gg,kwedges)$name,tail_of(gg,kwedges)$name)),paste0(head_of(gg,kwedges)$name,' ',tail_of(gg,kwedges)$name)),file='modelography/kwsraw.csv')


#########
## citation core
write.table(data.frame(V(citationcore)$title,V(citationcore)$name,V(citationcore)$year,V(citationcore)$citmemb),row.names = F,col.names = F,file='modelography/citationcore.csv',sep=',')




########
## consolidate

corpus = read.csv(file='modelography/corpus_manual.csv',header=F,sep=';',colClasses = c('character','character','character'))
citcore = read.csv(file='modelography/citationcore_manual.csv',header=F,sep=',',colClasses = c('character','character','character','character'))

full = rbind(cbind(corpus,V4=rep(NA,nrow(corpus))),citcore)

full = full[!duplicated(full$V2),]

write.table(full,row.names = F,col.names = F,sep=";",file='modelography/full.csv')


#####
## first stats

full=as.tbl(read.csv(file='modelography/full_manual.csv',header=T,sep=';',colClasses = rep('character',16)))
full$TEMPSCALE<-as.numeric(full$TEMPSCALE)
full$DISCIPLINE<-as.factor(full$DISCIPLINE)
full$METHODO<-as.factor(full$METHODO)

table(full$MODEL)

summary(lm(TEMPSCALE~DISCIPLINE+METHODO,data=full))

# chisquare tests







