
# analyses

library(Matrix)
library(ggplot2)

probas = export_probas[,2:ncol(export_probas)]


##
# publication-level originality

originalities=apply(probas,MARGIN = 1,FUN = function(r){if(sum(r)==0){return(0)}else{return(1 - sum(r^2))}})

dat=data.frame(originality=originalities,cyb=iscyb)
sdat=as.tbl(dat)%>%group_by(cyb)%>%summarise(mean=mean(originality))
gp=ggplot(dat)
gp+geom_density(aes(x=originality, fill=cyb),alpha=.3)+geom_vline(data=sdat, aes(xintercept=mean,  colour=cyb),linetype="dashed", size=1)+
  geom_density(data=data.frame(null=borig),aes(x=null),linetype="dashed")


## null model

kwlength=mean(sapply(V(g)$name,nchar))
abstractlengths=sapply(keyword_dico,length)
names(abstractlengths)<-1:length(abstractlengths)
memberships<-sub$com$membership
weighteddegree=strength(sub$gg)
nullweights=list();for(k in unique(memberships)){nullweights[[k]]=weighteddegree[which(sub$com$membership==k)]}
drawWeights<-function(m){w=c();for(k in m){w=append(w,sample(nullweights[[k]],1))};return(w)}

bsize=100000
borig=c()
for(b in 1:bsize){
  if(b%%1000==0){show(b)}
  nkws = floor(sample(abstractlengths,1)/kwlength)+1
  m=sample(memberships,nkws,replace=TRUE);w=drawWeights(m)
  dprobas=list();for(k in 1:length(m)){if(!(as.character(m[k]) %in% names(dprobas))){dprobas[[as.character(m[k])]]=w[k]}else{dprobas[[as.character(m[k])]]=dprobas[[as.character(m[k])]]+w[k]}}
  borig=append(borig,1-sum((sapply(dprobas,function(x){x/sum(w)}))^2))
}

dat=data.frame(originality=c(originalities,borig),type=c(rep("pubs",length(originalities)),rep("null",length(borig))))
sdat=as.tbl(dat)%>%group_by(type)%>%summarise(mean=mean(originality))  
ggplot(dat, aes(x=originality, fill=type)) + geom_density(alpha=.3)+geom_vline(data=sdat, aes(xintercept=mean,  colour=type),linetype="dashed", size=1)



##
#  2nd order interdisciplinarities

# OUT

m=Diagonal(nrow(citadjacency),1/rowSums(citadjacency))
citnorm=m%*%citadjacency
citorigsout=data.frame(rownames(probas))
for(j in 1:ncol(probas)){
  citorigsout = cbind(citorigsout,as.numeric(citnorm%*%Matrix(as.matrix(probas[,j]),sparse=TRUE)[,1]))
}
citorigsout=citorigsout[,2:ncol(citorigsout)]
indexes = rowSums(citadjacency)>0

#length(which(rowSums(citadjacency)>0|colSums(citadjacency)>0))
# == size of vertices with links.

outoriginalities=apply(citorigsout[indexes,],MARGIN = 1,FUN = function(r){if(sum(r)==0){return(0)}else{return(1 - sum(r^2))}})

dat=data.frame(orig=outoriginalities,cyb=iscyb[indexes])
sdat=as.tbl(dat)%>%group_by(cyb)%>%summarise(mean=mean(orig))
gp=ggplot(dat, aes(x=orig, fill=cyb))
gp+ geom_density(alpha=.3)+geom_vline(data=sdat, aes(xintercept=mean,  colour=cyb),linetype="dashed", size=1)+
  xlab("out originality")+ggtitle(paste0("N = ",length(which(indexes))))

####
#IN

m=Diagonal(ncol(citadjacency),1/(sapply(colSums(citadjacency),function(x){max(1,x)})))
citnorm=citadjacency%*%m
citorigs=data.frame(rownames(probas))
for(j in 1:ncol(probas)){
  citorigs = cbind(citorigs,as.numeric(Matrix(probas[,j],ncol=nrow(probas),sparse=TRUE)%*%citnorm))
}
citorigs=citorigs[,2:ncol(citorigs)]

indexes = colSums(citadjacency)>0
originalities=apply(citorigs[indexes,],MARGIN = 1,FUN = function(r){if(sum(r)==0){return(0)}else{return(1 - sum(r^2))}})

dat=data.frame(orig=originalities,cyb=iscyb[indexes])
sdat=as.tbl(dat)%>%group_by(cyb)%>%summarise(mean=mean(orig))
gp=ggplot(dat, aes(x=orig, fill=cyb))
gp+ geom_density(alpha=.3)+geom_vline(data=sdat, aes(xintercept=mean,  colour=cyb),linetype="dashed", size=1)+
  xlab("in originality")+ggtitle(paste0("N = ",length(which(indexes))))



# --> corresponds to citation regimes
#  : try nb cit = f(in orig)
#   also with out ?




###
#  IN + OUT

indexes = rowSums(citadjacency)>0|colSums(citadjacency)>0

outoriginalities=apply(citorigsout[indexes,],MARGIN = 1,FUN = function(r){if(sum(r)==0){return(0)}else{return(1 - sum(r^2))}})
originalities=apply(citorigs[indexes,],MARGIN = 1,FUN = function(r){if(sum(r)==0){return(0)}else{return(1 - sum(r^2))}})
originalities = (outoriginalities+originalities)/2

dat=data.frame(orig=originalities,cyb=iscyb[indexes])
sdat=as.tbl(dat)%>%group_by(cyb)%>%summarise(mean=mean(orig))
gp=ggplot(dat, aes(x=orig, fill=cyb))
gp+ geom_density(alpha=.3)+geom_vline(data=sdat, aes(xintercept=mean,  colour=cyb),linetype="dashed", size=1)+
  xlab("in/out originality")+ggtitle(paste0("N = ",length(which(indexes))))








