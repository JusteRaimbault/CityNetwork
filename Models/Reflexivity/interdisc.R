

# (following sensitivity)

library(ggplot2)
library(reshape2)
source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

source(paste0(Sys.getenv('CN_HOME'),'/Models/QuantEpistemo/HyperNetwork/HyperNetwork/functions.R'))
source(paste0(Sys.getenv('CN_HOME'),'/Models/QuantEpistemo/HyperNetwork/HyperNetwork/networkConstruction.R'))


setwd(paste0(Sys.getenv('CN_HOME'),'/Models/Reflexivity'))

figdir=paste0(Sys.getenv('CN_HOME'),'/Results/Reflexivity/')

mongobase='reflexivity';kwLimit=50000;eth_graph=10
kminopt=0;kmaxopt=500;freqminopt=0;freqmaxopt=10000;ethopt=5

load(paste0('processed/',mongobase,'_probas_',kwLimit,'_eth',eth_graph,'_nonfiltdico_kmin',kminopt,'_kmax',kmaxopt,'_freqmin',freqminopt,'_freqmax',freqmaxopt,'_eth',ethopt,'.RData'))
#sub<-extractSubGraphCommunities(semantic,kminopt,kmaxopt,freqminopt,freqmaxopt,ethopt)
coms=sub$com;gg=sub$gg

graphfile=paste0(mongobase,'_network_',kwLimit,'_eth',eth_graph,'_nonfiltdico')

load(paste0(Sys.getenv('CN_HOME'),'/Models/Reflexivity/processed/',graphfile,'.RData'))
semantic=res$g;
keyword_dico=res$keyword_dico
rm(res);gc()
mongoids <-read.csv('data/mongoids.csv',colClasses = c('character'))
names(keyword_dico)<-mongoids$id


# content of communities

for(k in sort(unique(coms$membership))){
  if(k==18){
  show(paste0('Com ',k,', size : ',length(which(coms$membership==k)),' , weight docs : ',100*colSums(probas)[k]/sum(probas)))
   vertices=(coms$membership==k)
   currentnames=V(gg)$name[vertices];currentdegree=degree(gg)[vertices]
   #degth = sort(currentdegree,decreasing = T)[min(20,length(currentdegree))]
   #show(data.frame(name=currentnames[currentdegree>degth],degree=currentdegree[currentdegree>degth]))
    show(currentnames)
  }
}

semnames <- c('toxicology','chemistry','political science','theoretical ecology','urban systems (french)',
              'sustainibility','innovation economics','maup','physiology','NA','physics',
              'networks','bioanthropology','health','statistics','microbiology',
              'transportation','biological network','copyrights','publication',
              'health geography','botanics','evolution','ecology','formulas','genetics'
              )


# export network
write_graph(induced_subgraph(gg,which(degree(gg)>20)),file='processed/semsubgraph_degsup20.gml',format = 'gml')

# save(gg,coms,probas,semantic,keyword_dico,file='processed/semantic.RData')

####
rownames(probas)<-names(keyword_dico)
colnames(probas)<-semnames

# extract citation graph with probas

subcit = induced_subgraph(citationcore,which(V(citationcore)$name%in%rownames(probas)[rowSums(probas)>0]))
#subcit = induced_subgraph(citation,which(V(citation)$name%in%rownames(probas)[rowSums(probas)>0]))
subprobas = probas[V(subcit)$name,]
#subprobas = probas

# interdisciplinarity
interdisc = data.frame(interdisc = 1 - apply(subprobas^2,1,sum),id=as.character(rownames(subprobas)),citclass =  unlist(sapply(as.character(V(subcit)$citmemb),function(n){ifelse(n%in%names(citcomnames),unlist(citcomnames[n]),'NA')})))

g=ggplot(interdisc[interdisc$citclass!='NA',],aes(x=interdisc,colour=citclass))
g+geom_density(alpha=0.3)+stdtheme+xlab('interdisciplinarity')+scale_color_discrete(name='Cit. Class')
ggsave(file=paste0(figdir,'interdisciplinarities.png'),width=30,height=15,units = 'cm')


# composition of citation coms
selectedsem = c('political science','urban systems (french)',
                'sustainibility','innovation economics','physics',
                'networks','bioanthropology','health','statistics','microbiology',
                'transportation','biological network',
                'health geography','ecology','genetics')
selectedsemdisplay = c('political\nscience','urban\nsystems',
                       'sustainibility','innovation\neconomics','physics',
                       'networks','bioanthropology','health','statistics','microbiology',
                       'transportation','biological network',
                       'health\ngeography','ecology','genetics')

compos=c();cit=c();sem=c()
for(citclass in names(citcomnames)){
  compos=append(compos,colSums(subprobas[interdisc$citclass==citcomnames[citclass],selectedsem]))
  cit=append(cit,unlist(rep(citcomnamesdisplay[citclass]),length(selectedsem)));sem=append(sem,selectedsemdisplay)
}

dd=data.frame(citclass=cit,semclass=sem,compo=compos)

g=ggplot(dd,aes(x=citclass,y=compo,fill=semclass))
g+geom_col()+xlab('Citation class')+ylab('Composition')+scale_colour_discrete(name='Semantic')#+stdtheme
ggsave(file=paste0(figdir,'compos.png'),width=40,height=20,units = 'cm')

# same with proportions
for(citclass in unique(dd$citclass)){dd$compo[dd$citclass==citclass]=dd$compo[dd$citclass==citclass]/sum(dd$compo[dd$citclass==citclass])}
g=ggplot(dd,aes(x=citclass,y=compo,fill=semclass))
g+geom_col()+xlab('Citation class')+ylab('Proportion')+scale_colour_discrete(name='Semantic')#+stdtheme
ggsave(file=paste0(figdir,'compo_proportion.png'),width=40,height=20,units = 'cm')


###
# Proximities between citation communities

# citation proximities

proxmat = matrix(0,length(citcomnames),length(citcomnames))
adj=A[rownames(subprobas),rownames(subprobas)]
for(i in 1:length(citcomnames)){
  for(j in 1:length(citcomnames)){
    proxmat[i,j]=sum(adj[interdisc$citclass==citcomnames[i],interdisc$citclass==citcomnames[j]])/sum(adj[interdisc$citclass==citcomnames[i],])
  }
}
rownames(proxmat)<-citcomnames;colnames(proxmat)<-citcomnames
dd=melt(proxmat[,rev(colnames(proxmat))])
dd$value=cut(dd$value,breaks = 11)

g=ggplot(dd,aes(x=Var1,y=Var2,fill=value))
g+geom_raster()+scale_fill_brewer(palette = 'Spectral',direction = -1,name='Proximity')+xlab('')+ylab('')
ggsave(file=paste0(figdir,'citation_proximities.png'),width=21,height=16,units = 'cm')


# semantic proximities

# prox between semantic classes
#t(subprobas[interdisc$citclass%in%citcomnames,])%*%subprobas[interdisc$citclass%in%citcomnames,]
# no time.

# tensor product to have semantic distance between cit classes
#  not : we could have done that in patents ?

docdist=matrix(0,nrow(subprobas),nrow(subprobas));rownames(docdist)<-rownames(subprobas);colnames(docdist)<-rownames(subprobas)
for(j in 1:ncol(subprobas)){
  docdist=docdist+(matrix(rep(subprobas[,j],nrow(subprobas)),nrow=nrow(subprobas),byrow = T) - matrix(rep(subprobas[,j],nrow(subprobas)),nrow=nrow(subprobas),byrow = F))^2
}
docdist=1-sqrt(docdist/2)

proxmat = matrix(0,length(citcomnames),length(citcomnames))
for(i in 1:length(citcomnames)){
  for(j in 1:length(citcomnames)){
    proxmat[i,j]=sum(docdist[interdisc$citclass==citcomnames[i],interdisc$citclass==citcomnames[j]])/(length(which(interdisc$citclass==citcomnames[i]))*length(which(interdisc$citclass==citcomnames[j])))
  }
}
rownames(proxmat)<-citcomnames;colnames(proxmat)<-citcomnames

dd=melt(proxmat[,rev(colnames(proxmat))])
dd$value=cut(dd$value,breaks = 11)

g=ggplot(dd,aes(x=Var1,y=Var2,fill=value))
g+geom_raster()+scale_fill_brewer(palette = 'Spectral',direction = -1,name='Proximity')+xlab('')+ylab('')
ggsave(file=paste0(figdir,'semantic_proximities.png'),width=21,height=16,units = 'cm')



###
# Correlation and modularity

# coonstruct citation proba matrix
semprobas = subprobas[interdisc$citclass%in%citcomnames,]

citprobas = matrix(0,nrow(semprobas),length(citcomnames)) # do it dirty
colnames(citprobas)<-citcomnames;rownames(citprobas)<-rownames(semprobas)
for(i in 1:nrow(citprobas)){citprobas[i,as.character(interdisc[rownames(citprobas)[i],"citclass"])]=1}

bcorrs=bootstrapped(semprobas,citprobas)
corrs = corrMat(semprobas,citprobas)
min(corrs);max(corrs);mean(abs(corrs))
apply(bcorrs,2,mean)
apply(bcorrs,2,sd)


# overlapping modularity
overlappingmodularity(semprobas,adj[rownames(semprobas),rownames(semprobas)])
overlappingmodularity(citprobas,adj[rownames(citprobas),rownames(citprobas)])

semmods=c();citmods=c()
for(b in 1:100){
  show(b)
  shuffled=adj[sample(rownames(semprobas),size=nrow(semprobas),replace = F),sample(rownames(semprobas),size=nrow(semprobas),replace = F)];
  semmods=append(semmods,overlappingmodularity(semprobas,shuffled))
  citmods=append(citmods,overlappingmodularity(citprobas,shuffled))
}

show(paste0('sem : ',mean(semmods),' +- ',sd(semmods)))
show(paste0('cit : ',mean(citmods),' +- ',sd(citmods)))






