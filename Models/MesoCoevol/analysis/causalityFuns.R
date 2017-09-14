

getFeature<-function(tau,rho,type="tau",fun=min,theta=0.1){
  names(rho)<-tau
  res = rho[which(rho==fun(rho))[1]]
  restau = names(res)[1]
  if(abs(res-mean(rho))/abs(mean(rho))<theta){res = 0;restau=0}
  if(type=="tau"){return(as.numeric(restau))}
  if(type=="rho"){return(res)}
}



getFeatures<-function(theta,withValues=TRUE){
  if(withValues==TRUE){
    resfeatures <- meancorrs %>% group_by(wdensity,wcenter,wroad)%>%summarise(
      rhomin_ctrrd=getFeature(tau[vars=="ctr->rd"],corr[vars=="ctr->rd"],"rho",min,theta),
      taumin_ctrrd=getFeature(tau[vars=="ctr->rd"],corr[vars=="ctr->rd"],"tau",min,theta),
      rhomax_ctrrd=getFeature(tau[vars=="ctr->rd"],corr[vars=="ctr->rd"],"rho",max,theta),
      taumax_ctrrd=getFeature(tau[vars=="ctr->rd"],corr[vars=="ctr->rd"],"tau",max,theta),
      rhomin_densctr=getFeature(tau[vars=="dens->ctr"],corr[vars=="dens->ctr"],"rho",min,theta),
      taumin_densctr=getFeature(tau[vars=="dens->ctr"],corr[vars=="dens->ctr"],"tau",min,theta),
      rhomax_densctr=getFeature(tau[vars=="dens->ctr"],corr[vars=="dens->ctr"],"rho",max,theta),
      taumax_densctr=getFeature(tau[vars=="dens->ctr"],corr[vars=="dens->ctr"],"tau",max,theta), 
      rhomin_densrd=getFeature(tau[vars=="dens->rd"],corr[vars=="dens->rd"],"rho",min,theta),
      taumin_densrd=getFeature(tau[vars=="dens->rd"],corr[vars=="dens->rd"],"tau",min,theta),
      rhomax_densrd=getFeature(tau[vars=="dens->rd"],corr[vars=="dens->rd"],"rho",max,theta),
      taumax_densrd=getFeature(tau[vars=="dens->rd"],corr[vars=="dens->rd"],"tau",max,theta)
    )
  }else{
    resfeatures <- meancorrs %>% group_by(wdensity,wcenter,wroad)%>%summarise(
      taumin_ctrrd=getFeature(tau[vars=="ctr->rd"],corr[vars=="ctr->rd"],"tau",min,theta),
      taumax_ctrrd=getFeature(tau[vars=="ctr->rd"],corr[vars=="ctr->rd"],"tau",max,theta),
      taumin_densctr=getFeature(tau[vars=="dens->ctr"],corr[vars=="dens->ctr"],"tau",min,theta),
      taumax_densctr=getFeature(tau[vars=="dens->ctr"],corr[vars=="dens->ctr"],"tau",max,theta), 
      taumin_densrd=getFeature(tau[vars=="dens->rd"],corr[vars=="dens->rd"],"tau",min,theta),
      taumax_densrd=getFeature(tau[vars=="dens->rd"],corr[vars=="dens->rd"],"tau",max,theta)
    )
  }
  return(resfeatures)
}





