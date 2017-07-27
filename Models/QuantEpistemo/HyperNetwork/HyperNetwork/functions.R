library(Matrix)


# modularity
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



overlappingmodularity <- function(probas,adjacency){#,linkfun=function(p1,p2){return(p1*p2)}){
  show(paste0('Computing overlapping modularity : dim(probas)=',dim(probas)[1],' ',dim(probas)[2],' ; dim(adjacency)=',dim(adjacency)[1],' ',dim(adjacency)[2]))
  m = sum(adjacency)
  n=nrow(probas)
  kout=rowSums(adjacency)
  kin=colSums(adjacency)
  res=0
  for(c in 1:ncol(probas)){
    if(sum(probas[,c])>0){
      if(c%%100==0){show(c/ncol(probas))}
      a1 = Diagonal(x=probas[,c])%*%adjacency%*%Diagonal(x=probas[,c])
      a2 = sum(kout*probas[,c])*sum(kin*probas[,c])*((sum(probas[,c])/n)^2)/m
      res = res + sum(a1) - a2
      rm(a1);gc() # loose time to call gc at each step ?
    }
  }
  return(res/m)
}


corrMat <- function(p1,p2){
  ids = intersect(rownames(p1),rownames(p2))
  d1 <- p1[ids,];d2<-p2[ids,]
  d1 = Matrix(apply(d1,2,function(col){(col-mean(col))/sd(col)}))
  d2 = Matrix(apply(d2,2,function(col){(col-mean(col))/sd(col)}))
  return(t(d1)%*%d2/nrow(d1))
}



bootstrapped<-function(p1,p2){
  minrho=c();maxrho=c();meanabsrho=c()
  minrhosup=c();maxrhosup=c();meanabsrhosup=c()
  for(b in 1:1000){
    if(b%%100==0){show(b)}
    shuffled=p2;rownames(shuffled)<-sample(rownames(p2),size=nrow(p2),replace = F)
    cors = corrMat(p1,shuffled)
    minrho=append(minrho,min(cors));maxrho=append(maxrho,max(cors));meanabsrho=append(meanabsrho,mean(abs(cors)))
    shuffled=p1;rownames(shuffled)<-sample(rownames(p1),size=nrow(p1),replace = F)
    cors = corrMat(p2,shuffled)
    minrho=append(minrho,min(cors));maxrho=append(maxrho,max(cors));meanabsrho=append(meanabsrho,mean(abs(cors)))
    shuffled=p1;rows=sample.int(n=nrow(p1),size=0.5*nrow(p1),replace = FALSE)
    rownames(shuffled)[rows]<-sample(rownames(shuffled)[rows],size=length(rows),replace=F)
    cors = corrMat(p1,shuffled)
    minrhosup=append(minrhosup,min(cors));maxrhosup=append(maxrhosup,max(cors));meanabsrhosup=append(meanabsrhosup,mean(abs(cors)))
    shuffled=p2;rows=sample.int(n=nrow(p2),size=0.5*nrow(p2),replace = FALSE)
    rownames(shuffled)[rows]<-sample(rownames(shuffled)[rows],size=length(rows),replace=F)
    cors = corrMat(p2,shuffled)
    minrhosup=append(minrhosup,min(cors));maxrhosup=append(maxrhosup,max(cors));meanabsrhosup=append(meanabsrhosup,mean(abs(cors)))
  }
  return(data.frame(minrho,maxrho,meanabsrho,minrhosup,maxrhosup,meanabsrhosup))
}


