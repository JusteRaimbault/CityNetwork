

## functions

library(cartography)
library(classInt)


#'
#' @param accessorigdata
#' @param accessdestdata
#' @param weightmat
getLaggedCorrsDeltas <- function(accessorigdata,accessdestdata,weightmat,ydata,taumax=5){
  # ∆ accessibilities
  deltaacc = getDiffs(computeAccess(accessorigdata,accessdestdata,weightmat))
  # ∆ Y
  deltay = getDiffs(ydata)
  
  res=data.frame()
  for(tau in -taumax:taumax){
    laggedX = deltaacc;laggedX$year = sapply(as.character(as.numeric(laggedX$year)+2000+tau),function(s){substr(s,3,4)})
    joined = left_join(laggedX,deltay,by=c("id"="id","year"="year"))
    joined=joined[!is.na(joined$var.y),]
    #show(length(which(!is.na(joined$var.y))))
    corrs = cor.test(joined$var.x,joined$var.y)
    #cor.test(joined$var.x,joined$var.y)
    estimate = ifelse(corrs$p.value<0.05,corrs$estimate,0)
    rhomin = ifelse(corrs$p.value<0.05,corrs$conf.int[1],0)
    rhomax = ifelse(corrs$p.value<0.05,corrs$conf.int[2],0)
    res=rbind(res,data.frame(rho=estimate,rhomin = rhomin,rhomax=rhomax,tau=tau,pval=corrs$p.value,tstat=corrs$statistic))
  }
  return(res)
}

#'
#' with window and variables themselves
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




#'
#' @description Compute accessibilities
#' @param allmats : acc mat , or function of year giving it
computeAccess<-function(accessorigdata,accessdestdata=NULL,matfun,d0=1,mode="time"){
  if(is.null(dim(accessorigdata))){
    # simple data vector
    weightmat = exp(-matfun / d0)
    data = accessorigdata
    potod = which(names(data)%in%rownames(weightmat)&!is.na(data))
    if(mode=="time"){Pi=rep(1,length(potod));Pj=matrix(rep(1,length(potod)),nrow=length(potod))}
    if(mode=="weighteddest"){Pi=rep(1,length(potod));Pj=matrix(data[potod],nrow=length(potod))}
    if(mode=="weightedboth"){Pi=data[potod];Pj=matrix(data[potod],nrow=length(potod))}
    access = Pi*((weightmat[,names(data)[potod]]%*%Pj)[names(data)[potod],])
    return(access)
  }else{
    # data frame of yearly data
    accessyears = unique(accessorigdata$year)
    allaccess = data.frame()
    for(year in accessyears){
      if(is.matrix(matfun)){weightmat=matfun}else{weightmat=matfun(year)}
      yearlyaccessorig = accessorigdata[accessorigdata$year==year,]
      potorig = which(yearlyaccessorig$id%in%rownames(weightmat)&!is.na(yearlyaccessorig$var))
      potdest = which(accessdestdata$id%in%colnames(weightmat)&!is.na(accessdestdata$var))
      Pi = yearlyaccessorig$var[potorig];
      Ej = matrix(accessdestdata$var[potdest],nrow=length(potdest))
      access = Pi*(weightmat[,accessdestdata$id[potdest]]%*%Ej)[yearlyaccessorig$id[potorig],]#/(sum(Pi)*sum(Ej)*sum(weightmat[yearlyaccessorig$id[potorig],accessdestdata$id[potdest]]))
      allaccess=rbind(allaccess,data.frame(var = access,id=names(access),year=rep(year,length(access))))
      rm(weightmat);gc()
    }
    allaccess$id=as.character(allaccess$id);allaccess$year=as.character(allaccess$year)
    return(allaccess)
  }
}

#'
#' specific function sa
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



#'
#' Compute deltas from timely data frame
getDiffs<-function(d,varname="var"){
  years = unique(d$year)
  res = data.frame()
  for(i in 2:length(years)){
    varprev = as.data.frame(d[d$year==years[i-1],]);var=as.data.frame(d[d$year==years[i],])
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
#' get nw matrices as a function of year
varyingNetwork<-function(m,decay,breakyear){
  return(function(nwyear){
    if(as.numeric(nwyear)<as.numeric(breakyear)){return(exp(-dmat_base/decay))}
    else{return(exp(-m/decay))}
  })
}




map<-function(data,layer,spdfid,dfid,variable,filename,title,legendtitle="",
              extent=NULL,withLayout=T,legendRnd=2,width=15,height=10,nclass=10,
              palette='Spectral',lwd=0.01,additionalLinelayers=NULL,additionalPointlayers=NULL){
  
  graphicsext = strsplit(filename,split='.',fixed=T)[[1]][2]
  if(graphicsext=='png'){png(file=filename,width=width,height=height,units='cm',res=1200)}
  if(graphicsext=='pdf'){ pdf(file=filename,width=width,height=height)}
  
  if(withLayout==T){par(mar = c(0.4,0.4,2,0.4))}else{par(mar = c(0.4,0.4,0.4,0.4))}
  
  #plot.new()
  
  layoutLayer(title = ifelse(withLayout,title,""), sources = "",
              author = "", col = ifelse(withLayout,"grey","white"), coltitle = "black", theme = NULL,
              bg = NULL, scale=NULL , frame = withLayout, north = F, south = FALSE,extent=extent)
  
  breaks=classIntervals(data[,variable],nclass)
  
  plot(layer, border = NA, col = "white",add=T)
  
  cols <- carto.pal(pal1 = "green.pal",n1 = floor(nclass/2), pal2 = "red.pal",n2 = floor(nclass/2))
  if(palette=='Spectral'){cols = rev(brewer.pal(nclass,'Spectral'))}
  
  
  choroLayer(spdf = layer,spdfid = spdfid,
             df = data,dfid = dfid,
             var=variable,
             col=cols,colNA='lightgrey',breaks=breaks$brks,
             add=TRUE,lwd = lwd,
             legend.pos = "n"
  )
  
  # additional layers
  if(!is.null(additionalLinelayers)){
    for(l in additionalLinelayers){
      plot(l, col = "blue",add=T)
    }
  }
  
  if(!is.null(additionalPointlayers)){
    for(l in additionalPointlayers){
      plot(l, col = "blue",pch=20,size=1,add=T)
    }
  }
  
  legendChoro(pos =  "bottomleft",title.txt = legendtitle,
              title.cex = 0.8, values.cex = 0.6, breaks$brks, cols, cex = 0.7,
              values.rnd = legendRnd, nodata = TRUE, nodata.txt = "No data",
              nodata.col = 'lightgrey', frame = FALSE, symbol = "box"
  )
  #plot(states,border = "grey20", lwd=0.75, add=TRUE)
  
  # additional transportation layer
  
  
  dev.off()
  
}





