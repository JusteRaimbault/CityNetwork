

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
for(citclass in unique(dd$citclass)){dd$compo[dd$citclass==citclass]=}







