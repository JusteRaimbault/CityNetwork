

## functions

library(cartography)



#'
#' @param accessorigdata
#' @param accessdestdata
#' @param weightmat
getLaggedCorrs <- function(accessorigdata,accessdestdata,weightmat,ydata){
  # ∆ accessibilities
  deltaacc = getDiffs(computeAccess(accessorigdata,accessdestdata,weightmat))
  # ∆ Y
  deltay = getDiffs(ydata)
  
  res=data.frame()
  for(tau in -5:5){
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
#' @description Compute accessibilities
#'
#' @param allmats : acc mat , or funciton of year giving it
computeAccess<-function(accessorigdata,accessdestdata,matfun){
  accessyears = unique(accessorigdata$year)
  allaccess = data.frame()
  for(year in accessyears){
    if(is.matrix(matfun)){weightmat=matfun}else{weightmat=matfun(year)}
    yearlyaccessorig = accessorigdata[accessorigdata$year==year,]
    potorig = which(yearlyaccessorig$id%in%rownames(weightmat)&!is.na(yearlyaccessorig$var))
    potdest = which(accessdestdata$id%in%colnames(weightmat)&!is.na(accessdestdata$var))
    Pi = yearlyaccessorig$var[potorig];Ej = matrix(accessdestdata$var[potdest],nrow=length(potdest))
    access = Pi*(weightmat[,accessdestdata$id[potdest]]%*%Ej)[yearlyaccessorig$id[potorig],]
    allaccess=rbind(allaccess,data.frame(var = access,id=names(access),year=rep(year,length(access))))
    rm(weightmat);gc()
  }
  allaccess$id=as.character(allaccess$id);allaccess$year=as.character(allaccess$year)
  return(allaccess)
}

#'
#' Compute deltas from timely data frame
getDiffs<-function(d){
  years = unique(d$year)
  res = data.frame()
  for(i in 2:length(years)){
    varprev = as.data.frame(d[d$year==years[i-1],]);var=as.data.frame(d[d$year==years[i],])
    rownames(varprev)<-varprev$id;rownames(var)<-var$id
    common = intersect(rownames(varprev),rownames(var))
    #show(var[rownames(var),])
    res=rbind(res,data.frame(id=common,var=var[common,"var"]-varprev[common,"var"],year=rep(years[i],length(common))))
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




map<-function(data,layer,variable,filename,title,legendtitle="",extent=NULL,withLayout=T,legendRnd=2){
  
  #png(file=paste0(resdir,'average_regular_march_map.png'),width=10,height=6,units='cm',res=600)
  pdf(file=paste0(resdir,filename,'.pdf'),width=10,height=5.5)#paper='a4r')
  
  if(withLayout){par(mar = c(0.4,0.4,2,0.4))}else{par(mar = c(0.4,0.4,0.4,0.4))}
  
  
  layoutLayer(title = ifelse(withLayout,title,""), sources = "",
              author = "", col = ifelse(withLayout,"grey","white"), coltitle = "black", theme = NULL,
              bg = NULL, scale=NULL , frame = withLayout, north = F, south = FALSE,extent=extent)
  
  breaks=classIntervals(data[,variable],20)
  
  plot(states, border = NA, col = "white",add=T)
  cols <- carto.pal(pal1 = "green.pal",n1 = 10, pal2 = "red.pal",n2 = 10)
  choroLayer(spdf = layer,spdfid = "GEOID",
             df = data,dfid = 'countyid',
             var=variable,
             col=cols,breaks=breaks$brks,
             add=TRUE,lwd = 0.01,
             legend.pos = "n"
  )
  legendChoro(pos = "left",title.txt = legendtitle,
              title.cex = 0.8, values.cex = 0.6, breaks$brks, cols, cex = 0.7,
              values.rnd = legendRnd, nodata = TRUE, nodata.txt = "No data",
              nodata.col = "white", frame = FALSE, symbol = "box"
  )
  plot(states,border = "grey20", lwd=0.75, add=TRUE)
  
  dev.off()
  
}


