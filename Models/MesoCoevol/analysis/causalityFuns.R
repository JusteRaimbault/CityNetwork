

getFeature<-function(tau,rho,type="tau",fun=min,theta=0.1){
  names(rho)<-tau
  res = rho[which(rho==fun(rho))[1]]
  restau = names(res)[1]
  if(abs(res-mean(rho))/abs(mean(rho))<theta){res = 0;restau=0}
  if(type=="tau"){return(as.numeric(restau))}
  if(type=="rho"){return(res)}
}






