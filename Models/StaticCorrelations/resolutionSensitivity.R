
setwd(paste0(Sys.getenv('CN_HOME'),'/Models/StaticCorrelations'))

source('functions.R')
source('mapFunctions.R')
source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

library(Matrix)

countrycode="FR"

resdir=paste0(Sys.getenv('CN_HOME'),'/Results/StaticCorrelations/Morphology/Coupled/Sensitivity/',countrycode,'/')
dir.create(resdir)

areasize=200;offset=100;factor=0.5
res200 = loadIndicatorData(paste0("res/europecoupled_areasize",areasize,"_offset",offset,"_factor",factor,"_temp.RData"))

areasize=100;offset=50;factor=0.5
res100 = loadIndicatorData(paste0("res/europecoupled_areasize",areasize,"_offset",offset,"_factor",factor,"_temp.RData"))

areasize=60;offset=30;factor=0.5
res60 = loadIndicatorData(paste0("res/europecoupled_areasize",areasize,"_offset",offset,"_factor",factor,"_temp.RData"))

res = list("60"=res60,"100"=res100,"200"=res200)

######
#unique(sort(sdata1$latmin))
#unique(sort(sdata2$latmin))

countries = readOGR('gis','countries')
country = countries[countries$CNTR_ID==countrycode,]

datapoints = list();sdata = list()
for(asize in c("60","100","200")){
  cdatapoints = SpatialPoints(data.frame(res[[asize]][,c("lonmin","latmin")]),proj4string = countries@proj4string)
  selectedpoints = gContains(country,cdatapoints,byid = TRUE);sdata[[asize]] = res[[asize]][selectedpoints,]
  datapoints[[asize]]=cdatapoints[selectedpoints,]
}


#plot(datapoints1)
#plot(datapoints2,pch=".",col='red',add=T)

lower = '60'
higher = '100'

#indics = 
# "vcount"             "ecount"             "gamma"              "meanDegree"         "mu"                
# "alpha"              "meanLinkLength"     "meanNodePop"        "meanClustCoef"      "components"        
# "meanBetweenness"    "alphaBetweenness.x" "euclPerf"           "diameter"           "meanCloseness"     
# "alphaCloseness.x"   "meanTravelTime"     "alphaTravelTime.x"  "alphaAccessibility" "meanAccessibility" 
# "modularity" 
indics = list(
  morpho = c("moran","averageDistance","entropy","rankSizeAlpha"),
  network = c("vcount","meanLinkLength","meanClustCoef","meanBetweenness","alphaBetweenness.x","meanCloseness","alphaCloseness.x")
)

dmat = spDists(datapoints[[higher]]@coords,datapoints[[lower]]@coords,longlat = T)

for(type in c('morpho','network')){

corrs=c();cindics=c();d0s=c()
corrmin=c();corrmax=c()
for(d0 in seq(1,25,2)){
  show(d0)
  M = exp(-dmat/d0)
  W = Diagonal(x=1/rowSums(M))%*%Matrix(M)
  for(indic in indics[[type]]){
    # use the weight matrix to compute smoothed field
    # correlations make sense on intensive indices only
   X = matrix(data=sdata[[lower]][,indic],nrow=ncol(W));X[is.na(X)]=0
   Y = W%*%X
   rho = cor.test(sdata[[higher]][,indic],Y[,1])
   corrs=append(corrs,rho$estimate)
   corrmin=append(corrmin,rho$conf.int[1]);corrmax=append(corrmax,rho$conf.int[2])
   d0s=append(d0s,d0);cindics=append(cindics,indic)
  }
  rm(M,W);gc()
}

g=ggplot(data.frame(rho=corrs,rhomin=corrmin,rhomax=corrmax,d0=d0s,indic=cindics),aes(x=d0,y=rho,ymin=rhomin,ymax=rhomax,color=indic,group=indic))
g+geom_point()+geom_line()+geom_errorbar(width=0.75)+xlab(expression(d[0]))+ylab(expression(rho*"["*X*"*"*W[d[0]]*","*X[ref]*"]"))+scale_colour_discrete(name="Indicateur")+stdtheme
ggsave(filename = paste0(resdir,'sensit_',type,'_low',lower,'_high',higher,'.png'),width = 20,height=12,units='cm')
}

#map(c(3),'moran_corresp.png',20,18,c(1,1),sdata=data.frame(lonmin=sdata1$lonmin,latmin=sdata1$latmin,moran=((sdata1$moran+Y[,1])/2)^10))








