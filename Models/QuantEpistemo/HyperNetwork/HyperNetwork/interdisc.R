

# (following sensitivity)

sub<-extractSubGraphCommunities(semantic,kminopt,kmaxopt,freqminopt,freqmaxopt,ethopt)
coms=sub$com;gg=sub$gg

load(paste0('processed/',mongobase,'_probas_',kwLimit,'_eth',eth_graph,'_nonfiltdico_kmin',kminopt,'_kmax',kmaxopt,'_freqmin',freqminopt,'_freqmax',freqmaxopt,'_eth',ethopt))

# content of communities

for(k in unique(coms$membership)){
  show(paste0('Com ',k,', size : ',length(which(coms$membership==k)),' , weight docs : ',100*colSums(probas)[k]/sum(probas)))
   vertices=(coms$membership==k)
   currentnames=V(gg)$name[vertices];currentdegree=degree(gg)[vertices]
   degth = sort(currentdegree,decreasing = T)[10]
   show(data.frame(name=currentnames[currentdegree>degth],degree=currentdegree[currentdegree>degth]))
}

semnames <- c('Maritime Networks','Accessibility','Sustainable Transport','Socio-economic','Policy',
              'Remote Sensing','Measuring','Agent-based Modeling','French Geography','Climate Change',
              'Environment','High Speed Rail','Transportation planning','Traffic','Health Geography',
              'Spanish Geography','Freight and Logistics','Mobility Data Mining','Education','Networks'
              )

# export network
write_graph(gg,file=paste0(figdir,'subgraph.gml'),format = 'gml')


####
rownames(probas)<-names(keyword_dico)
colnames(probas)<-semnames

# extract citation graph with probas

subcit = induced_subgraph(citationcore,which(V(citationcore)$name%in%rownames(probas)[rowSums(probas)>0]))
subprobas = probas[V(subcit)$name,]

# interdisciplinarity
interdisc = data.frame(interdisc = 1 - apply(subprobas^2,1,sum),citclass =  unlist(sapply(as.character(V(subcit)$citmemb),function(n){ifelse(n%in%names(citcomnames),unlist(citcomnames[n]),'NA')})))

g=ggplot(interdisc[interdisc$citclass!='NA',],aes(x=interdisc,colour=citclass))
g+geom_density(alpha=0.3)+stdtheme+xlab('interdisciplinarity')+scale_color_discrete(name='Cit. Class')
ggsave(file=paste0(figdir,'interdisciplinarities.png'),width=20,height=10,units = 'cm')


# composition of citation coms
#dd=as.tbl(data.frame(content=c(subprobas),semclass=c(matrix(rep(semnames,nrow(subprobas)),byrow = F)),citclass=rep(as.character(interdisc$citclass),ncol(subprobas))))
#compos = dd%>%group_by(citclass,semclass)%>%summarise(compo=sum(content))
# why u no work ? # do it by hand ? -> OK FUCKING Factor
selectedsem = c('Networks','Policy','Socio-economic','High Speed Rail','Education','Climate Change','Remote Sensing','Sustainable Transport')

compos=c();cit=c();sem=c()
for(citclass in citcomnames){
  compos=append(compos,colSums(subprobas[interdisc$citclass==citclass,selectedsem]))
  cit=append(cit,rep(citclass,length(selectedsem)));sem=append(sem,selectedsem)
}

dd=data.frame(citclass=cit,semclass=sem,compo=compos)

g=ggplot(dd,aes(x=citclass,y=compo,fill=semclass))
g+geom_col()+xlab('Citation class')+ylab('Composition')+scale_colour_discrete(name='Semantic')#+stdtheme
ggsave(file=paste0(figdir,'compos.png'),width=20,height=10,units = 'cm')

# same with proportions
for(citclass in unique(dd$citclass)){dd$compo[dd$citclass==citclass]=dd$compo[dd$citclass==citclass]/sum(dd$compo[dd$citclass==citclass])}
g=ggplot(dd,aes(x=citclass,y=compo,fill=semclass))
g+geom_col()+xlab('Citation class')+ylab('Proportion')+scale_colour_discrete(name='Semantic')#+stdtheme
ggsave(file=paste0(figdir,'compo_proportion.png'),width=20,height=10,units = 'cm')


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






