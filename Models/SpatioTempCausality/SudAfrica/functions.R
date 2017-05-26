

#'
#'
getDiffs<-function(d,varname="var"){
  years = unique(d$year)
  #show(years)
  res = data.frame()
  for(i in 2:length(years)){
    #show(years[i])
    varprev = as.data.frame(d[d$year==years[i-1],]);var=as.data.frame(d[d$year==years[i],])
    #show(nrow(varprev));show(length(which(duplicated(varprev$id))))
    #show(nrow(var));show(length(which(duplicated(var$id))))
    varprev<-varprev[!duplicated(varprev$id),]
    var<-var[!duplicated(var$id),]
    rownames(varprev)<-varprev$id;rownames(var)<-var$id
    common = intersect(rownames(varprev),rownames(var))
    #show(var[rownames(var),])
    res=rbind(res,data.frame(id=common,var=var[common,varname]-varprev[common,varname],year=rep(years[i],length(common))))
  }
  res$id=as.character(res$id);res$year=as.character(res$year)
  return(res)
}


#'
#' accessibility on yearly data
computeAccess<-function(data,distmat,d0,mode="time"){
  weightmat = exp(-distmat / d0)
  potod = which(names(data)%in%rownames(weightmat)&!is.na(data))
  if(mode=="time"){Pi=rep(1,length(potod));Pj=matrix(rep(1,length(potod)),nrow=length(potod))}
  if(mode=="weighteddest"){Pi=rep(1,length(potod));Pj=matrix(data[potod],nrow=length(potod))}
  if(mode=="weightedboth"){Pi=data[potod];Pj=matrix(data[potod],nrow=length(potod))}
  access = Pi*((weightmat[,names(data)[potod]]%*%Pj)[names(data)[potod],])
  return(access)
}


deltaAccessibilities<-function(d0,mode="time"){
  ids=c();accs=c();cyears=c()
  # compute all accs
  for(year in years){
    pop = populations$pop[populations$year==year];names(pop)<-populations$id[populations$year==year]
    distmat = distmats[[as.character(year)]]
    currentacc = computeAccess(pop,distmat,d0,mode=mode)
    ids=append(ids,names(currentacc));accs=append(accs,currentacc);cyears=append(cyears,rep(year,length(currentacc)))
  }
  return(getDiffs(d = data.frame(id=ids,year=cyears,var=accs)))
}



getLaggedCorrs <- function(x,y,Tw,taumax){
  res=data.frame()
  for(t0 in 2:(length(years)-Tw+1)){
    #show(t0)
    tf=t0+Tw-1;currentyears=as.character(years[t0:tf]);span=paste0(years[t0],"-",years[tf])
    currentx = x[x$year%in%currentyears,]
    for(tau in -taumax:taumax){
      laggedy = y;laggedy$year = sapply(laggedy$year,function(yy){i=which(as.character(years)==yy);if((i+tau)<1|(i+tau)>length(years)){return("0")}else{return(as.character(years)[i+tau])}})
      joined = left_join(currentx,laggedy,by=c("id"="id","year"="year"))
      joined=joined[!is.na(joined$var.y),]
      if(nrow(joined)>1){
        corrs = cor.test(joined$var.x,joined$var.y)
        estimate = ifelse(corrs$p.value<0.1,corrs$estimate,0)
        rhomin = ifelse(corrs$p.value<0.1,corrs$conf.int[1],0)
        rhomax = ifelse(corrs$p.value<0.1,corrs$conf.int[2],0)
        res=rbind(res,data.frame(rho=estimate,rhomin = rhomin,rhomax=rhomax,tau=tau,span=span,pval=corrs$p.value,tstat=corrs$statistic))
      }
    }
  }
  return(res)
}






