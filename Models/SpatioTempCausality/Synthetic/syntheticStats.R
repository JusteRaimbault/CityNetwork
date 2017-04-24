
# statistical tests on synthetic data

library(dplyr)
library(ggplot2)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/Statistics/Synthetic/'))

list.files('res/exploration')

d=as.tbl(read.csv("rdb/06_19_29.714_PM_02-juin-2016.csv",sep=";"))
#d=as.tbl(read.csv("rdb/05_46_43.391_PM_02-juin-2016.csv",sep=";"))
#d=d[d$t>40,]

#d %>% group_by(x,y) %>% summarise(deltad = density[1:(length(density)-1)]-density[2:length(density)])
# 
deltad = data.frame()
for(t in (min(d$t)+5):max(d$t)){
   deltad=rbind(deltad,cbind(d[d$t==t,4:7]-d[d$t==t-1,4:7],t=rep(t,length(which(d$t==t)))))
}

# 
# ###
# ## small test on ts clustering
# data = data.frame(deltad[deltad$t==2,1:4])
# for(t in (min(deltad$t)+1):max(deltad$t)){
#   data=cbind(data,deltad[deltad$t==t,1:4])
# }
# 
# data = data.frame(d[d$t==2,4:7])
# for(t in (min(d$t)+1):max(d$t)){
#   data=cbind(data,d[d$t==t,4:7])
# }
# 
# km=kmeans(data,2,nstart = 10,iter.max = 10000)
# centers=km$centers
# 
# plot(centers[1,seq(from=2,to=ncol(centers),by=4)],type='l')
# plot(centers[2,seq(from=2,to=ncol(centers),by=4)],type='l',col='red')
# 
# x=centers[2,seq(from=9,to=ncol(centers),by=4)]
# y=centers[2,seq(from=10,to=ncol(centers),by=4)]
# x=(x-min(x))/(max(x)-min(x));y=(y-min(y))/(max(y)-min(y))
# 
# plot(x,type='l');points(y,type='l',col='red')

# NO NEED TO NORMALIZE, EXACTLY THE SAME AS WORK ON CORRELATIONS
#deltad$density=deltad$density/max(abs(deltad$density))
#deltad$cdistance=deltad$cdistance/max(abs(deltad$cdistance))

# second order
#ddeltad = data.frame()
#for(t in 3:max(deltad$t)){
#  ddeltad=rbind(ddeltad,cbind(deltad[deltad$t==t,]-deltad[deltad$t==t-1,],t=rep(t,length(which(deltad$t==2)))))
#}


# plot the variables in time
#deltad=deltad[deltad$density!=0&deltad$cdistance!=0,]
#dd1=cbind(deltad[,c(1,5)],var=rep("∆density",nrow(deltad)));names(dd1)<-c("var","t","varname")
#dd2=cbind(deltad[,c(2,5)],var=rep("∆dcenter",nrow(deltad)));names(dd2)<-c("var","t","varname")

#g=ggplot(rbind(dd1,dd2),aes(x=t,y=var,colour=varname))
#g+geom_point(pch='+',cex=2)+stat_smooth(method = "loess",span=0.3)+ylim(-0.3,1.0)


# compute lagged correlation : -15:15
laggedcors=data.frame()
n=length(which(deltad$t==min(deltad$t)))
for(tau in 0:15){
  x=deltad$density[1:(nrow(deltad)-(n*tau))];y=deltad$cdistance[((n*tau)+1):nrow(deltad)]
  rho=cor.test(x[x!=0&y!=0],y[x!=0&y!=0])
  #rho=cor.test(x,y)
  laggedcors=rbind(laggedcors,data.frame(tau,rho=rho$estimate,rhomin=rho$conf.int[1],rhomax=rho$conf.int[2]))
}
for(tau in 1:15){
  x=deltad$cdistance[1:(nrow(deltad)-(n*tau))];y=deltad$density[((n*tau)+1):nrow(deltad)]
  rho=cor.test(x[x!=0&y!=0],y[x!=0&y!=0])
  #rho=cor.test(x,y)
  laggedcors=rbind(laggedcors,data.frame(tau=-tau,rho=rho$estimate,rhomin=rho$conf.int[1],rhomax=rho$conf.int[2]))
}

g=ggplot(laggedcors,aes(x=tau,y=rho))
g+geom_point()+geom_errorbar(aes(ymin=rhomin,ymax=rhomax))+stat_smooth(method = "loess",span=0.7)




# 
#dd=as.tbl(ddeltad[,c(1:4,6)])%>%group_by(t)%>%summarise(density=mean(density),cdistance=mean(cdistance))
#laggedcors=data.frame()
#for(tau in 0:15){
#  rho=cor.test(dd$density[1:(nrow(dd)-(tau))],dd$cdistance[(tau+1):nrow(dd)])
#  laggedcors=rbind(laggedcors,data.frame(tau,rho=rho$estimate,rhomin=rho$conf.int[1],rhomax=rho$conf.int[2]))
#}
#for(tau in 1:15){
#  rho=cor.test(dd$cdistance[1:(nrow(dd)-(tau))],dd$density[(tau+1):nrow(dd)])
#  laggedcors=rbind(laggedcors,data.frame(tau=-tau,rho=rho$estimate,rhomin=rho$conf.int[1],rhomax=rho$conf.int[2]))
#}




####

# test ; relatively dirty

#setup-headless 1.0 1.0 1.0 1 1
laggedcorrs1=c(0.004983943130202901,-0.002872117393436301,1.56315163973317E-4,0.01662677831077169,0.002213543172378789,-0.021987842581165224,-0.017996544420702112,0.008780224644680182,-0.0023072820446895814,0.00967611188497608,0.014288194591331805,0.002793732775251284,-9.952592372543512E-4,0.03050649525216768,-0.02288414493808128,0.026109556808006522,-0.011728572689976244,-0.009411338385753903,-0.008814726813306036,-0.006770572664009209,-0.0065767081435637404,-0.009172205640591713,-0.010621777780008682,-0.010693575855346305,-5.481252227972086E-5,-0.0073747715884674905,-0.009426776403422736,-0.008582581180784147,-4.531570788186584E-4,-0.004769413391677501,-0.009272101689586563)
#setup-headless 1.0 1.0 1.0 1 10
laggedcorrs2=c(0.008071482579104143,0.013059677387697411,-0.005187523989538144,-0.009687685273413217,-0.013556703458342725,0.028410042949936844,-0.0069985490190470475,-0.002766743261237125,7.0109302572013E-4,0.009623822906545999,-0.009629244551334681,-0.005700956513335551,-9.895886843633644E-4,3.269331985077178E-4,-9.177855669419702E-4,0.015392164844126928,-0.012126534357656298,-0.010825342054296784,-0.012681130483326034,-0.010673788984677694,-0.010618139822797145,-0.003035428906272028,-0.006275235539908006,-0.002161025523093887,-0.0020886365408650095,3.301053023811022E-4,-0.0010180967002832418,-0.006667364519488209,-0.004543351704643522,-0.010998329502235307,-0.003612751332041262)
#setup-headless 1.0 1.0 1.0 1 15
laggedcorrs3=c(-0.017906095986772112,-0.00465652587735404,0.002261263391908627,0.02546785799047635,-0.020168117380782065,0.006568213409096463,0.011205867918395264,-0.007940662706036895,-0.009203989109673405,-0.018241165643191143,0.006613808050170712,-0.009411109634769441,0.0027312111958141295,0.006047909941154971,0.025523600865344078,0.012876902839527098,-0.012952596558881261,-0.015216931757654024,-0.00963582571992511,-0.009569011406247663,-7.848533077582828E-4,-0.004865939315925408,-0.003528520285069572,-0.004385361116778621,-0.002321062225747624,-0.0054821048446364925,-0.0027576194766878266,-0.007597960187091253,-0.008227122426658242,-0.013517712120542782,-0.0044902592469388556)
#setup-headless 1.0 1.0 1.0 1 20
laggedcorrs4=c(-0.006432369746883126,-5.479112404464171E-4,-6.206801448664181E-4,-0.0072420636651874554,0.0029088456677243695,0.01624359279558795,8.162296503166488E-4,-0.001555510979959554,-0.006898734928816627,-0.011363330983184596,-0.003067433339769952,-0.006164313792509891,9.988283119418348E-4,0.027554801698447404,0.016842392933753367,0.024442031564964616,-0.01506717564926248,-0.01672964694461556,-0.016400676612990037,-0.015925063545255833,-0.011713269324096994,-0.01206807679979646,-0.01078294798028023,-0.001079130559788392,-0.0043893626989623315,-0.006316894418276872,-0.006442215353639298,-9.655711179582899E-4,-0.009438821258249257,-0.006008255880369381,-0.00774605005228282)
#setup-headless 1.0 1.0 1.0 1 25
laggedcorrs5=c(-0.007569646548636175,-0.014354913502723683,0.027969211082668463,0.004613654458435035,-0.02154509920166677,-0.004088953991140542,-0.0121392031172796,-0.008783572616754479,-0.009984973118805389,-0.004425071739338834,-0.005014422931946757,-0.008036499594621714,0.005667530593553025,0.0056911624916577185,0.014609072742523547,0.014981697491840496,-0.008900929927002055,-0.007768540914830981,-0.009690122529205742,-0.00260040290901347,-0.013133451684813608,-0.007462445320879346,-0.0067556021121225095,-0.008642261549705602,-0.005480144963806239,-0.005646476270310091,0.0021075393939107363,-0.007485997166529888,-0.006219073444909781,-0.008993786838745077,0.0029273381833426287)
#setup-headless 1.0 1.0 1.0 1 35
laggedcorrs6=c(0.025709061381814204,-0.02465770935579279,-0.0016377171343935311,-5.399352722168367E-4,-0.005589136098864093,0.025644512860092346,0.005230073967811824,-0.008838606103584171,0.011908947863091863,-0.0014080798203411626,-0.0015004611639804597,-0.0020515457058923646,-0.007220471548610317,0.03554110244828346,-0.008464217442940203,0.027035457913219596,-0.016103326935438672,-0.012853239060643408,-0.01095232849834588,-0.014952924517083285,-0.013457464843312568,-0.011781129487566974,-0.002788584854112939,-0.009377960390625335,-0.011920085899437471,0.004150561424895759,-0.005840685869654976,-0.006122902931500117,-0.009545791163930164,-0.007579211188555317,-0.012413123837842027)


g=ggplot(data.frame(tau=rep(-15:15,6),corr=c(laggedcorrs1,laggedcorrs2,laggedcorrs3,laggedcorrs4,laggedcorrs5,laggedcorrs6)),aes(x=tau,y=corr))
g+geom_point()+stat_smooth(span = 0.3)



#############
# test (non flat corr arrays)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/Simple/ModelCA/'))
d=as.tbl(read.csv("res/exploration/2017_02_06_15_37_01_test.csv",sep=","))

corr = c()
for(rep in unique(d$replication)){corr=append(corr,
                                              #d$rhoDensCentre[d$replication==rep]
                                              #d$rhoDensRoad[d$replication==rep]
                                              d$rhoCentrRoad[d$replication==rep]
                                              )}

g=ggplot(data.frame(tau=rep(-15:15,length(unique(d$replication))),corr=corr),aes(x=tau,y=corr))
g+geom_point(size=0.2)+stat_smooth(method="loess",span=0.1)


#############
# test

#setwd(paste0(Sys.getenv('CN_HOME'),'/Models/Simple/ModelCA/'))
setwd(paste0(Sys.getenv('CN_HOME'),'/Results/Statistics/Synthetic/rdb/20170210_gridexplo/'))

resdir = paste0(Sys.getenv('CN_HOME'),'/Results/Statistics/Synthetic/rdb/20170210_gridexplo/')

#d=as.tbl(read.csv("res/exploration/2017_02_07_10_56_26_gridexplo.csv",sep=",",header = FALSE,stringsAsFactors = FALSE))
d=as.tbl(read.csv("data/2017_02_10_18_41_22_gridexplo.csv",sep=",",header = FALSE,stringsAsFactors = FALSE))
d = d[2:nrow(d),]
for(j in 1:ncol(d)){d[,j]=as.numeric(unlist(d[,j]))}
#taumax=8
taumax = 10
colnames(d)<-c("centerNumber","globalDensity","id","localDensity","moran","networkSpeed","replication",paste0("rhoCentrRoad",-taumax:taumax),paste0("rhoDensCentre",-taumax:taumax),paste0("rhoDensRoad",-taumax:taumax),"weightCenter","weightDensity","weightRoad")
d$param_id = paste0(d$weightRoad,"-",d$weightCenter,"-",d$weightDensity)

corr = c();tau=c();vars=c();pars=c()
wd=c();wc=c();wr=c()
dd = matrix(rep(0,(2*taumax + 1)*6*3*nrow(d)),ncol=6)
for(i in 1:(nrow(d))){
#for(i in which(d$weightRoad==0)){
  if(i%%1000==0){show(i)}
  #corr=append(corr,unlist(d[i,8:(8+(2*taumax))]))
  #corr=append(corr,unlist(d[i,(9+(2*taumax)):(9+(4*taumax))]))
  #corr=append(corr,unlist(d[i,(10+(4*taumax)):(10+(6*taumax))]))
  dd[((i-1)*(2*taumax + 1)*3 + 1):((i-1)*(2*taumax + 1)*3 + 2*taumax + 1),1] = unlist(d[i,8:(8+(2*taumax))])
  dd[((i-1)*(2*taumax + 1)*3 + 2*taumax + 2):((i-1)*(2*taumax + 1)*3 + 4*taumax + 2),1] = unlist(d[i,(9+(2*taumax)):(9+(4*taumax))])
  dd[((i-1)*(2*taumax + 1)*3 + 4*taumax + 3):((i-1)*(2*taumax + 1)*3 + 6*taumax + 3),1] = unlist(d[i,(10+(4*taumax)):(10+(6*taumax))])
  #tau = append(tau,rep(-taumax:taumax,3))
  #vars = append(vars,c(rep("ctr->rd",2*taumax+1),rep("dens->ctr",2*taumax+1),rep("dens->rd",2*taumax+1)))
  #pars = append(pars,rep(d$param_id[i],3*(2*taumax+1)))
  #wd=append(wd,rep(d$weightDensity[i],3*(2*taumax+1)));wc=append(wc,rep(d$weightCenter[i],3*(2*taumax+1)));wr=append(wr,rep(d$weightRoad[i],3*(2*taumax+1)))
  dd[((i-1)*(2*taumax + 1)*3 + 1):(i*(2*taumax + 1)*3),2] = rep(-taumax:taumax,3)
  dd[((i-1)*(2*taumax + 1)*3 + 1):(i*(2*taumax + 1)*3),3] = c(rep("ctr->rd",2*taumax+1),rep("dens->ctr",2*taumax+1),rep("dens->rd",2*taumax+1))
  dd[((i-1)*(2*taumax + 1)*3 + 1):(i*(2*taumax + 1)*3),4] = rep(d$weightDensity[i],3*(2*taumax+1))
  dd[((i-1)*(2*taumax + 1)*3 + 1):(i*(2*taumax + 1)*3),5] = rep(d$weightCenter[i],3*(2*taumax+1))
  dd[((i-1)*(2*taumax + 1)*3 + 1):(i*(2*taumax + 1)*3),6] = rep(d$weightRoad[i],3*(2*taumax+1))
}

# !! matrix of strings --> HUGE mistake for performance ?

colnames(dd)<-c("corr","tau","vars","wdensity","wcenter","wroad")
#dd[,1]<-as.numeric(dd[,1]);dd[,2]<-as.numeric(dd[,2]);dd[,4]<-as.numeric(dd[,4]);dd[,5]<-as.numeric(dd[,5]);dd[,6]<-as.numeric(dd[,6])
#dd = data.frame(corr=corr,tau=tau,vars=vars,wdensity=wd,wcenter=wc,wroad=wr)#,pars=pars)
dd = data.frame(corr=as.numeric(dd[,1]),tau=as.numeric(dd[,2]),vars=dd[,3],wdensity=as.numeric(dd[,4]),wcenter=as.numeric(dd[,5]),wroad=as.numeric(dd[,6]))#,pars=pars)
# ultra dirty, very strange type handling
#save(dd,file=paste0(Sys.getenv('CN_HOME'),'/Models/Statistics/Synthetic/visu/data/20170210.RData')) # save to reuse in shiny app

g=ggplot(dd,aes(x=tau,y=corr,colour=vars))
g+geom_point(size=0.2)+stat_smooth(method="loess",span=0.1)+facet_wrap(~pars,scales = "free")

sdd=dd[dd$wdensity%in%c(0,1)&dd$wcenter%in%c(0,1)&dd$wroad%in%c(0,1),]
pars = paste0(sdd$wdensity,"-",sdd$wcenter,"-",sdd$wroad)
g=ggplot(data.frame(sdd,pars=pars),aes(x=tau,y=corr,colour=vars))
g+geom_point(size=0.2)+stat_smooth(method="loess",span=0.1)+facet_wrap(~pars,scales = "free",nrow = 2)+theme(legend.position = c(0.85, 0.15))+ylab("Lagged correlation")
ggsave(paste0(resdir,'laggedcorrs_facetextreme.png'),width=35,height=20,units = 'cm')


# with facet grid
g=ggplot(dd,aes(x=tau,y=corr,colour=vars))
g+geom_point(size=0.2)+stat_smooth(method="loess",span=0.1)+facet_grid(wd~wc,sc)


###########
## try to identify typical regimes by clustering


# compute mean
meancorrs = as.tbl(dd) %>% group_by(wdensity,wcenter,wroad,vars,tau) %>% summarise(
  corr=mean(corr)
)

meancorrs$vars=as.character(meancorrs$vars)

# features
#  tau_min,rho_min,tau_max,rho_max

# do with summarise, not optimal but more ergonomic
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

#theta=0.25
thetas=seq(from=0.5,to=3.0,by=0.5)
thstr=paste0(thetas[1],"-",thetas[length(thetas)])
knums=2:15

for(withValues in c(TRUE,FALSE)){

  ccoef=c();cthetas=c();cknums=c();cdcoef=c();cdthetas=c();cdknums=c()
  for(theta in thetas){
    show(theta)
    features=getFeatures(theta,withValues = withValues)

    for(k in knums){
      show(k)
      km = kmeans(features[,4:ncol(features)],k,iter.max = 1000,nstart=5000)
      ccoef=append(ccoef,km$betweenss/km$totss);cknums=append(cknums,k)
    }
    cthetas=append(cthetas,rep(theta,length(knums)))

    cdcoef = append(cdcoef,diff(ccoef[(length(ccoef)-length(knums)+1):length(ccoef)]))
    cdknums = append(cdknums,knums[2:length(knums)]);cdthetas=append(cdthetas,rep(theta,length(knums)-1))
  }


  g=ggplot(data.frame(ccoef=ccoef,knums=knums,theta=cthetas),aes(x=knums,y=ccoef,group=theta,color=theta))
  g+geom_point()+geom_line()+xlab('Number of clusters')+ylab('Between-cluster variance proportion')
  ggsave(file=paste0(resdir,'ccoef-knum_values',withValues,'_theta',thstr,'.pdf'),width=15,height=10,units = 'cm')
  
  
  g=ggplot(data.frame(cdcoef=cdcoef,knums=cdknums,theta=cdthetas),aes(x=cdknums,y=cdcoef,group=theta,color=theta))
  g+geom_point()+geom_line()+xlab('Number of clusters')+ylab('Between-cluster variance proportion increase')
  ggsave(file=paste0(resdir,'dccoef-knum_values',withValues,'theta',thstr,'.pdf'),width=15,height=10,units = 'cm')
}

##
# compute cluster center trajectories
#  -> plot representative of regimes
#theta=2.0
#k=5

withValues=FALSE
for(k in c(5,6,7)){
for(theta in c(1.0,2.0)){
  show(paste0('k=',k,';theta=',theta))
  
features=getFeatures(theta,withValues = withValues)
km = kmeans(features[,4:ncol(features)],k,iter.max = 1000,nstart=5000)
clusters=as.character(km$cluster)
#nath=0.01
#for(i in 1:nrow(features)){sdists = sort(t(apply(km$centers,1,function(r){sqrt(sum((as.numeric(features[i,4:ncol(features)])-r)^2))})),decreasing = T);th=2*abs(sdists[1]-sdists[2])/(sdists[1]+sdists[2]);if(th<nath){show(th);clusters[i]=NA}}
features$cluster=clusters

g=ggplot(features,aes(x=wdensity,y=wcenter,fill=cluster))
g+geom_raster()+facet_wrap(~wroad)+theme(legend.position = c(0.85, 0.15))+guides(fill=guide_legend(ncol=2))
ggsave(file=paste0(resdir,'clusters-paramfacet_values',withValues,'theta',theta,'_k',k,'.png'),width=15,height=10,units = 'cm')

## plot features in a principal component plane
fcoords = features[,4:(ncol(features)-1)]
pr=prcomp(fcoords)
rotated = as.matrix(fcoords)%*%pr$rotation

g=ggplot(data.frame(rotated,cluster=features$cluster),aes(x=PC1,y=PC2,color=cluster))
g+geom_point()
ggsave(file=paste0(resdir,'clusters-PCA-features_values',withValues,'theta',theta,'_k',k,'.png'),width=12,height=10,units = 'cm')

#   some cleaning on extreme points ? / middle points ? -> not concluding

# NOTE : adding values does not change much result
centertrajs=data.frame()
for(k in 1:nrow(km$centers)){
  show(k)
  pvals = features[features$cluster==as.character(k),1:3]
  currentcorrs=data.frame()
  for(i in 1:nrow(pvals)){
    currentcorrs=rbind(currentcorrs,meancorrs[meancorrs$wdensity==pvals$wdensity[i]&meancorrs$wcenter==pvals$wcenter[i]&meancorrs$wroad==pvals$wroad[i],])
  }
  sumcorrs=currentcorrs%>%group_by(vars,tau)%>%summarise(rho=mean(corr))
  centertrajs = rbind(centertrajs,cbind(sumcorrs,cluster=as.character(k)))
}

g=ggplot(centertrajs,aes(x=tau,y=rho,color=vars,group=vars))
g+geom_point()+geom_line()+facet_wrap(~cluster)
ggsave(file=paste0(resdir,'clusters-centertrajs-facetclust_values',withValues,'theta',theta,'_k',k,'.png'),width=20,height=10,units = 'cm')

g=ggplot(centertrajs,aes(x=tau,y=rho,color=cluster,group=cluster))
g+geom_point()+geom_line()+facet_wrap(~vars)
ggsave(file=paste0(resdir,'clusters-centertrajs-facetvars_values',withValues,'theta',theta,'_k',k,'.png'),width=20,height=10,units = 'cm')

}
}






