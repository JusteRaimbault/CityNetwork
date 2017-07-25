
# synthetic graph representation of communities

# source semexport.R

# foreach non-NA thematic : split into cyb/noncyb to have nodes
#   node code : them1 : cyb ; them0 : other
#   link type code : 0:them ; 1:cit.


probas = export_probas[,2:ncol(export_probas)]

# the power of sparse matrices - et bim !
#citadjacency = get.adjacency(gcitation,sparse=TRUE)[names(keyword_dico),names(keyword_dico)]
#citadjacency[!iscyb,!iscyb]%*%c1[!iscyb]

# fuck off with data.frame and factors : construct df after
  
from=c();to=c();weight=c();type=c()
ncyb=sum(citadjacency[iscyb,]);nncyb=sum(citadjacency[!iscyb,])
for(tn1 in colnames(probas)){
  c1 = probas[[tn1]]
  # same theme citation links
  #cyb->cyb
  prov=citadjacency[iscyb,iscyb]%*%c1[iscyb];w=sum(prov[,1]*c1[iscyb])/(ncyb*sum(c1[iscyb]));from=append(from,paste0(tn1,"1"));to=append(to,paste0(tn1,"1"));weight=append(weight,w);type=append(type,2)
  #ncyb->ncyb
  prov=citadjacency[!iscyb,!iscyb]%*%c1[!iscyb];w=sum(prov[,1]*c1[!iscyb])/(nncyb*sum(c1[!iscyb]));from=append(from,paste0(tn1,"0"));to=append(to,paste0(tn1,"0"));weight=append(weight,w);type=append(type,2)
  #cyb->ncyb
  prov=citadjacency[iscyb,!iscyb]%*%c1[!iscyb];w=sum(prov[,1]*c1[iscyb])/(ncyb*sum(c1[iscyb]));from=append(from,paste0(tn1,"1"));to=append(to,paste0(tn1,"0"));weight=append(weight,w);type=append(type,2)
  #ncyb->cyb
  prov=citadjacency[!iscyb,iscyb]%*%c1[iscyb];w=sum(prov[,1]*c1[!iscyb])/(nncyb*sum(c1[!iscyb]));from=append(from,paste0(tn1,"0"));to=append(to,paste0(tn1,"1"));weight=append(weight,w);type=append(type,2)
  
  # add type 2 link : to have vertices close in layout
  #from=append(from,paste0(tn1,"0"));to=append(to,paste0(tn1,"1"));weight=append(weight,10000);type=append(type,2)
  
  
  for(tn2 in colnames(probas)){
    if(tn1!=tn2){
      show(paste0(tn1,' - ',tn2))
      c2 = probas[[tn2]]
      # thematic links
      themlinkcybweight = sum(c1[iscyb]*c2[iscyb])#2*sum(apply(data.frame(c1[iscyb],c2[iscyb]),1,min))
      themlinkotherweight = sum(c1[!iscyb]*c2[!iscyb]) #2*sum(apply(data.frame(c1[!iscyb],c2[!iscyb]),1,min))
      #from=append(from,paste0(tn1,"1"));to=append(to,paste0(tn2,"1"));weight=append(weight,themlinkcybweight);type=append(type,0)
      #from=append(from,paste0(tn1,"0"));to=append(to,paste0(tn2,"0"));weight=append(weight,themlinkotherweight);type=append(type,0)
      from=append(from,tn1);to=append(to,tn2);weight=append(weight,themlinkcybweight);type=append(type,0)
      from=append(from,tn1);to=append(to,tn2);weight=append(weight,themlinkotherweight);type=append(type,1)
      
      
      
      # citation links
      #cyb->cyb
      prov=citadjacency[iscyb,iscyb]%*%c2[iscyb];w=sum(prov[,1]*c1[iscyb])/(ncyb*sum(c1[iscyb]));from=append(from,paste0(tn1,"1"));to=append(to,paste0(tn2,"1"));weight=append(weight,w);type=append(type,2)
      #cyb->ncyb
      prov=citadjacency[iscyb,!iscyb]%*%c2[!iscyb];w=sum(prov[,1]*c1[iscyb])/(ncyb*sum(c1[iscyb]));from=append(from,paste0(tn1,"1"));to=append(to,paste0(tn2,"0"));weight=append(weight,w);type=append(type,2)
      #ncyb->cyb
      prov=citadjacency[!iscyb,iscyb]%*%c2[iscyb];w=sum(prov[,1]*c1[!iscyb])/(nncyb*sum(c1[!iscyb]));from=append(from,paste0(tn1,"0"));to=append(to,paste0(tn2,"1"));weight=append(weight,w);type=append(type,2)
      #ncyb->ncyb
      prov=citadjacency[!iscyb,!iscyb]%*%c2[!iscyb];w=sum(prov[,1]*c1[!iscyb])/(nncyb*sum(c1[!iscyb]));from=append(from,paste0(tn1,"0"));to=append(to,paste0(tn2,"0"));weight=append(weight,w);type=append(type,2)
      
    }
  }
}


edf = data.frame(from,to,weight,type)

gsynthcit = graph_from_data_frame(edf[edf$type==2,])
gsynththemcyb = graph_from_data_frame(edf[edf$type==0,],directed=FALSE)
gsynththemnoncyb = graph_from_data_frame(edf[edf$type==1,],directed=FALSE)

vthematics = sapply(V(gsynthcit)$name,function(s){sub("1","",sub("0","",s))})
#vcol=1:length(unique(vthematics));names(vcol)=unique(vthematics);vcol=vcol[vthematics]
vlabels =  sapply(V(gsynthcit)$name,function(s){sub("1"," (Cyb)",sub("0"," (N-Cyb)",s))})

V(gsynthcit)$thematics = vthematics
V(gsynthcit)$label = vlabels

#write.graph(gsynththemcyb,file = paste0(exdir,'/synththemcyb.gml'),format = "gml")
#write.graph(gsynththemnoncyb,file = paste0(exdir,'/synththemnoncyb.gml'),format = "gml")
write.graph(gsynthcit,file = paste0(exdir,'/gsynthcit_renorm.gml'),format = "gml")


#ecurve = as.integer(E(gsynth)$type==1)*0.5
#ewidth =1+(E(gsynth)$weight/max(E(gsynth)$weight))*as.integer(E(gsynth)$type==0)# as.integer(E(gsynth)$type==0)*E(gsynth)$weight#floor((1 + 100 * E(gsynth)$weight/max(E(gsynth)$weight)))
#earrow = as.integer(E(gsynth)$type!=0)

#plot(gsynth,layout=layout.circle(gsynth),palette=rainbow(length(vthematics)),
#     vertex.color = vcol,vertex.label=vlabels,vertex.size=3,vertex.label.cex=0.8,vertex.label.dist=0,
#     edge.curved = ecurve,edge.lty=ewidth,edge.arrow.mode=0,edge.width=ewidth
#     )




