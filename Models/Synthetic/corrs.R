
library(dplyr)
library(ggplot2)
library(reshape2)
library(boot)

#source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))
source(paste0(Sys.getenv('CS_HOME'),'/Organisation/Models/Utils/R/plots.R'))

setwd(paste0(Sys.getenv('CN_HOME'),'/Results/Synthetic/Network'))

#res <- read.csv('20151224_LHSLocal/2015_12_24_19_39_03_LHS_LOCAL.csv')
#res <- read.csv('20160106_LHSDensityNW/data/2016_01_06_21_47_22_LHS_DENSITYNW.csv')

# load multiple result files
# and bind them into single tbl -- must incr idpar before to avoid collisions
resdir='20160106_LHSDensityNW/data/'
figdir='20160106_LHSDensityNW/res/'

files <- list.files(resdir)
#res <- read.csv(paste0(resdir,files[4]))


res = as.tbl(read.csv(paste0(resdir,files[1])))
currentmaxidpar = max(res[,"idpar"])+1
for(f in files[2:length(files)]){
  temp <- as.tbl(read.csv(paste0(resdir,f)))
  temp[,"idpar"] = temp[,"idpar"]+currentmaxidpar
  #res = bind_rows(res,temp)
  res = rbind(res,temp)
  currentmaxidpar = max(res[,"idpar"])+1
}
for(j in 1:ncol(res)){res[,j]<-as.numeric(unlist(res[,j]))}

nrep=80

gres <- as.tbl(res) %>% filter(meanBwCentrality<=1&!is.na(meanBwCentrality)) %>% group_by(idpar)

# Test of summarise with list of functions [as strings] -> DOES NOT WORK
#l=list();l[["m"]]="mean(meanBwCentrality)"
#test <- gres %>% summarise(l)

# need to filter on group size
glength <- gres %>% summarise(groupLength = length(idpar))
length(glength$idpar[glength$groupLength==nrep])




#aggregated summary vars 
aggres <- gres  %>% filter(idpar %in% glength$idpar[glength$groupLength==nrep]) %>% summarise(
  bw = mean(meanBwCentrality),bws=sd(meanBwCentrality),
  pathlength = mean(meanPathLength),pathlengthsd = sd(meanPathLength),
  relspeed=mean(meanRelativeSpeed),relspeedsd=sd(meanRelativeSpeed),
  diameter=mean(nwDiameter),diametersd=sd(nwDiameter),
  length=mean(nwLength),lengthsd=sd(nwLength),
  moranIndex=mean(moran),moransd=sd(moran),
  distanceMean=mean(distance),distancesd=sd(distance),
  dentropy=mean(entropy),entropysd=sd(entropy),
  rslope=mean(slope),slopesd=sd(slope)
)
# DO NOT NAME NEW VARS AFTER OLD, AS SUMMARY IS DONE SEQUENTIALLY ON NEWLY CREATED COLUMNS -- SHITTY FEATURE
#aggres <- aggres %>% filter(!is.na(bw)&!is.na(bws))
indicnames = names(aggres)[seq(from=2,to=ncol(aggres)-1,by=2)]
indicsdnames = names(aggres)[seq(from=3,to=ncol(aggres),by=2)]

# parameters
params <- gres %>% filter(idpar %in% glength$idpar[glength$groupLength==nrep]) %>% summarise(
  alphalocalization=mean(alphalocalization),diffusion=mean(diffusion),diffusionsteps=mean(diffusionsteps),citiesNumber=mean(citiesNumber),growthrate=mean(growthrate/population),
  gravityHierarchyExponent=mean(gravityHierarchyExponent),gravityInflexion=mean(gravityInflexion),gravityRadius=mean(gravityRadius),
  hierarchyRole=mean(hierarchyRole),maxNewLinksNumber=mean(maxNewLinksNumber),pop=mean(population)
)
parnames = names(params)[2:(ncol(params)-1)]

#  compute cov/cor matrix for each point in param space

# nw block
#  no nwLength for the sake of simplicity
nwcormat <- gres %>% filter(idpar %in% glength$idpar[glength$groupLength==nrep]) %>% summarize_nwcormat
nwcormatmin <- gres %>% filter(idpar %in% glength$idpar[glength$groupLength==nrep]) %>% summarize_nwcormatmin
nwcormatmax <- gres %>% filter(idpar %in% glength$idpar[glength$groupLength==nrep]) %>% summarize_nwcormatmax

# density block
denscormat <- gres %>% filter(idpar %in% glength$idpar[glength$groupLength==nrep]) %>% summarize_denscormat
denscormatmin <- gres %>% filter(idpar %in% glength$idpar[glength$groupLength==nrep]) %>% summarize_denscormatmin
denscormatmax <- gres %>% filter(idpar %in% glength$idpar[glength$groupLength==nrep]) %>% summarize_denscormatmax

# cross correlations -- hardcore with CIs
crosscormat <- gres  %>% filter(idpar %in% glength$idpar[glength$groupLength==nrep]) %>% summarize_crosscorrmat


#summary(cormat[1,8:17])

crosscornames = paste0('cor',c(paste0('1',5:8),paste0('2',5:8),paste0('3',5:8),paste0('4',5:8)))

#cormat = crosscormat[,2:ncol(crosscormat)]
cormat = melt(crosscormat[,crosscornames],measure.vars = crosscornames,value.name = 'rho',variable.name = 'correlation')

# histograms of correlations
# -> log normal ? COMPARE WITH NULL MODEL ? which one ?
#par(mfrow=c(4,4),mar=c(1,1,1,1))
#for(j in (seq(from=1,to=ncol(cormat),by=3)+2)){
#  d=cormat[,j]
#  hist(unlist(d),breaks=50,main=colnames(cormat)[j],xlab="")
#  abline(v=mean(unlist(d)),col="red")
#  
#  #corj = cormat[[colnames(cormat)[j]]];show(mean(corj))
#  #rho = mean(corj)
#  # simulate correlated vectors of same size
#  #corrs = c();for(k in 1:1000){x1 = rnorm(1000,mean=0);corrs=append(corrs,cor(x1,rho*x1 +sqrt(1 - rho^2)*rnorm(1000,mean=0)))}
#  #ggplot(vegLengths, aes(length, fill = veg)) + geom_histogram(alpha = 0.5, aes(y = ..density..), position = 'identity')
#}

# reconstruct accurate names
morphonames = c("r","d","ε","a");nwnames=c("c","l","s","δ")
cormat$cornames = sapply(as.character(cormat$correlation),function(s){paste0("ϱ[",morphonames[as.numeric(substr(s,4,4))],",",nwnames[as.numeric(substr(s,5,5))-4],"]")})
                                                                             
# redo with ggplot
g=ggplot(cormat,aes(x=rho))
g+geom_histogram(bins=30)+facet_wrap(~cornames,nrow = 4)+
  geom_vline(data=cormat%>%group_by(cornames)%>%summarize(rho=mean(rho)),aes(xintercept=rho),color='red')+
  xlab("")+ylab("")+stdtheme+ theme(plot.margin =margin(0.5,0.5,0,0,unit = 'cm'))
ggsave(file=paste0(figdir,'/crosscor/hist_crossCorMat_breaks30.png'),width=20,height=20,units='cm')




##########
# Bootstrap experiment
#  (not used)



# test : pairwise correlations of subvectors ?
# - 50 subvector size ; idpar == 0
#
#  -- THIS IS BOOTSTRAP --
#
#point=1;subvecsize=20;subsamplesize=2000;
#fgres <- gres %>% filter(idpar==point)
#subsample = sample.int(n=nrow(fgres),size=subsamplesize,replace=FALSE);fgres <- fgres[subsample,]
#fgres <- fgres %>% mutate(row=1:nrow(fgres)) %>% mutate(subvec=floor((row-1)/subvecsize)+1)
#corrs = c();subvecnum=max(fgres$subvec)-1;
#for(i in 1:subvecnum){corrs = append(corrs,cor(c(as.data.frame(fgres%>%filter(subvec==i))$moran),as.data.frame(fgres%>%filter(subvec==i))$meanBwCentrality));}
#hist(corrs,breaks=50);mean(corrs);

#
#cor.test(fgres$moran,fgres$meanBwCentrality,method="pearson")$estimate
#library(boot)
#boot(fgres,function(data,i){cor(data$moran[i],data$meanBwCentrality[i])},1000)

# find a way to summarize corr matrices -> various norms ?
#  per var : max ; spread ; ?






##########
# HeatMaps

#nindics = c("bw-centrality","path-length","speed","diameter")
#mindics = c("moran","distance","entropy","slope")
# rename with variables
morphonames = c("r","d","ε","a")
nwnames = c("c","l","s","δ")

cormat = crosscormat[,2:ncol(crosscormat)]

maxcor = apply(crosscormat[,((0:(ncol(crosscormat)/3-1))*3+2)],2,function(c){max(c)})
mincor = apply(crosscormat[,((0:(ncol(crosscormat)/3-1))*3+2)],2,function(c){min(c)})
maxabscor = apply(crosscormat[,((0:(ncol(crosscormat)/3-1))*3+2)],2,function(c){max(abs(c))})
amplcor = apply(crosscormat[,((0:(ncol(crosscormat)/3-1))*3+2)],2,function(c){max(c)-min(c)})
meanabscor = apply(crosscormat[,((0:(ncol(crosscormat)/3-1))*3+2)],2,function(c){mean(abs(c))})


plotHeatmap<-function(var,title,filename){
df=melt(matrix(data=var,nrow=4,byrow=FALSE));names(df)=c("x","y","z")
g = ggplot(df) + scale_fill_gradient(low="yellow",high="red",name="")
g+geom_raster(aes(x,y,fill=z))+scale_x_discrete(limits=nwnames)+scale_y_discrete(limits=morphonames)+
  theme(axis.ticks = element_blank(),panel.background=element_blank(),
        legend.title=element_text(""),axis.text.x = element_text(vjust = 10,size=25),
        axis.text.y = element_text(hjust = 1.5,size=25),
        plot.title = element_text(hjust = 0.5,vjust=-10,size=20),
        legend.text=element_text(size=20),legend.position = c(1,0.5),
        plot.margin = margin(0, 2, 0, 0, "cm")
        )+
  labs(title=title,x="",y="")
ggsave(paste0(figdir,'crosscor/heatmap_',filename,'.png'),width=16,height=15,units='cm')
}

plotHeatmap(meanabscor,"Mean absolute correlations","mean-abs-corr")

plotHeatmap(amplcor,"Amplitude of correlations","amplitude")

plotHeatmap(maxabscor,"Maximal absolute correlations","max-abs-corr")



###########
## Point clouds


dgres = gres  %>% filter(idpar %in% glength$idpar[glength$groupLength==nrep])

cormat = crosscormat[,2:ncol(crosscormat)]
#cormat = nwcormat[,2:17]

# plot points on two first principal components

corrCols = 3*(0:floor((ncol(cormat)-1)/3))+1
pr = prcomp(cormat[,corrCols])
# normalize
#m = apply(pr$rotation,2,function(col){sum(abs(col))});mm=matrix(data=rep(m,nrow(pr$rotation)),nrow=nrow(pr$rotation),byrow=TRUE)
#rotation=pr$rotation/mm
rotation=pr$rotation
rcormat = as.matrix(cormat[,corrCols]) %*% as.matrix(rotation)
# brutal CI computation -> wrong as some rotation coefficient are negative
#rcormatmin = as.matrix(cormat[,corrCols+1]) %*% as.matrix(rotation)
#rcormatmax = as.matrix(cormat[,corrCols+2]) %*% as.matrix(rotation)
# std errors computation: rotate amplitude and take eucl dist -> which logic ?
#sigma1=apply(cormat[,corrCols+2]-cormat[,corrCols+1],1,function(r){sqrt(sum((r*c(rotation[,1]))^2))})
#sigma2=apply(cormat[,corrCols+2]-cormat[,corrCols+1],1,function(r){sqrt(sum((r*c(rotation[,2]))^2))})
rints = rotated_intervals(cormat,corrCols,cormat[,corrCols+1],cormat[,corrCols+2],rotation)
rcormatmin=rints$rcormatmin;rcormatmax=rints$rcormatmax

# bootstrap CI
#summary(boot(rcormat,function(data,i){data[i,1]},1000))




#plot(rcormat[,1],rcormat[,2])
# color according to mean correlation / other?
#as.tbl(as.data.frame(t(rcormat))) %>% transmute(m=(PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10)/10)
#apply(rcormat,1,mean)

#npoints = nrow(cormat)
#points = sample.int(nrow(rcormat),size=npoints,replace=FALSE)
points = 1:nrow(cormat)

# must filter according to extent -> minimize overlap and maximize total extent.
# Q : what about "real" morpho conf ? 
# -> select rows close to real points
#  source 'morpho_calib.R'.real
distance<-function(...,cloud){
  return(min(apply(cloud,1,function(r){sqrt(sum((r-c(...))^2))})))
}
real_raw = read.csv(paste0(Sys.getenv("CN_HOME"),'/Results/StaticCorrelations/Morphology/Density/Numeric/20150806_europe50km_10kmoffset_100x100grid.csv'),sep=";")
real=real_raw[!is.na(real_raw[,3])&!is.na(real_raw[,4])&!is.na(real_raw[,5])&!is.na(real_raw[,6])&!is.na(real_raw[,7])&!is.na(real_raw[,8])&!is.na(real_raw[,9]),]
real=real[real[,3]<quantile(real[,3],0.9)&real[,3]>quantile(real[,3],0.1)&real[,4]<quantile(real[,4],0.9)&real[,4]>quantile(real[,4],0.1)&real[,5]<quantile(real[,5],0.9)&real[,5]>quantile(real[,5],0.1)&real[,6]<quantile(real[,6],0.9)&real[,6]>quantile(real[,6],0.1),]

realdist = apply(aggres,1,function(r){distance(r["moranIndex"],r["distanceMean"],r["dentropy"],r["rslope"],cloud=real[,3:6])})
aggres <- aggres %>% mutate(realdist=realdist)
# proximity is higher than plot obtained [@commit 18fea221a596d5f43f16d37a03b4464174fcf753]
#  -> real points may have been normalized ? NO - same with normalized columns gives totally different results
#  -> distance itself may have been normalized ? NO - makes no sense in terms of scale
#  -> other real points file used to compute real distance ? NO - same file
#  -> other filterings ? (pop file, outliers, independant measurements) YES - filtering outliers only gives similar proximity range (0.43,0.99) (filtering pop gives min prox at 0.27)
#    -> keep that, logical to target "reasonable configurations"

# now filter on real dist ? -> no
#points= which(realdist<0.2)

# find points giving an optimal covering with error bars
# greedy algo : sequentially (in random order), add point if coverage overlaps not too much
#  -> overlap function, (([xmin,xmax],[ymin,ymax]),cloud)-> overlap
#overlap <- function(extent,cloud){
#   res = 0
#   if(length(cloud)>0){
#   for(i in 1:length(cloud)){
#     xd = max(extent[1],cloud[[i]][1])-min(extent[2],cloud[[i]][2])
#     yd = max(extent[3],cloud[[i]][3])-min(extent[4],cloud[[i]][4])
#     if(xd>0&yd>0){res=max(res,xd*yd)}
#   }
#   }
#   return(res)
#}

#overlapthreshold = 0.1
#points=c();cloud=list()
#for(i in 1:nrow(rcormat)){
#   a=abs((rcormatmax[i,1]-rcormatmin[i,1])*(rcormatmax[i,2]-rcormatmin[i,2]))
#   r=c(rcormatmin[i,1],rcormatmax[i,1],rcormatmin[i,2],rcormatmax[i,2])
#   show(overlap(r,cloud)/a)
#   if(overlap(r,cloud)/a<overlapthreshold){
#     points=append(points,i);cloud[[as.character(i)]]=r
#   }
#}

points = 1:nrow(rcormat)

cordata = data.frame(
  x=rcormat[points,1],
  y=rcormat[points,2],
  #xmin=rcormat[points,1]-sigma1,
  xmin=rcormatmin[points,1],
  #xmax=rcormat[points,1]+sigma1,
  xmax=rcormatmax[points,1],
  #ymin=rcormat[points,2]-sigma2,
  ymin=rcormatmin[points,2],
  #ymax=rcormat[points,2]+sigma2,
  ymax=rcormatmax[points,2],
  meanCor=apply(cormat,1,function(l){mean(abs(l))})[points],
  extent=apply(cormat,1,function(l){max(l)-min(l)})[points],
  maxCor=apply(cormat,1,function(l){max(l)})[points],
  minCor=apply(cormat,1,function(l){min(l)})[points],
  real=1-realdist[points],
  params[points,]
)


# read null model data
# $CS_HOME/SpatialData/library/data/coupled/null_model.csv
nullmodel = read.csv(file=paste0(Sys.getenv('CS_HOME'),'/SpatialData/library/data/coupled/nullmodel.csv'),sep=";")
names(nullmodel)[6]='meanBwCentrality';names(nullmodel)[2]='distance';names(nullmodel)[8]='meanRelativeSpeed';names(nullmodel)[9]='nwDiameter'
nullcormat = nullmodel %>% group_by(occupation,nodes.1,links,mode) %>% summarize_crosscorrmat
nullcorrcols = seq(from=5,to=ncol(nullcormat),by=3)
rnullcormat = as.matrix(nullcormat[,nullcorrcols]) %*% as.matrix(rotation)
rnullcormat = as.data.frame(rnullcormat)
rnullcormat$meanCor = apply(as.data.frame(nullcormat[,nullcorrcols]),1,function(l){mean(abs(l))})
rnullints = rotated_intervals(nullcormat,nullcorrcols,nullcormat[,nullcorrcols+1],nullcormat[,nullcorrcols+2],rotation)
rnullcormatmin=rnullints$rcormatmin;rnullcormatmax=rnullints$rcormatmax



specificpoints = cordata[(cordata$x<(-1.6)&cordata$y<(-1.25))|
                           (cordata$y>1.25&cordata$x<(-1.5))|
                           (cordata$y>(-0.07)&cordata$y<0&cordata$x>(-1)&cordata$x<(-0.75))|
                           (cordata$x>0&cordata$x<0.17&cordata$y<(-0.36))
                         ,]
specificpoints$label = c(1,2,4,3)
  
colvar="real";colname="Real\nproximity"
sizevar="meanCor";sizename="Average\nabsolute\ncorrelation";sizerange=c(0.8,4)
g = ggplot(cordata,aes_string(x="x",y="y",colour=colvar,size=sizevar))
g+geom_point(shape=19,alpha=0.8)+ scale_color_gradient(low="yellow",high="red",name=colname)+
  scale_size_continuous(range=sizerange,name=sizename)+
  geom_point(data=data.frame(x=rnullcormat[,1],y=rnullcormat[,2],size=rnullcormat[,"meanCor"]),mapping = aes(x=x,y=y,size=size),alpha=0.7,inherit.aes = F)+
  geom_point(data=specificpoints,aes(x=x,y=y),color='blue',shape=0,size=5,stroke=2,inherit.aes = F)+
  geom_text(data=specificpoints,aes(x=x,y=y,label=label),color='blue',size=5,hjust=-2,inherit.aes = F)+
  labs(title="",x="PC1",y="PC2")+stdtheme
ggsave(file=paste0(figdir,'crosscor/pca_realDistCol_meanAbsCorSize_withSpecificPoints.png'),width=20.3,height=19,units='cm')


# with error bars
# ! do not use point selection
colvar="meanCor";colname="Average\nabsolute\ncorrelation"
g = ggplot(cordata,aes_string(x="x",y="y",colour=colvar))
g+geom_errorbar(aes(ymin=ymin,ymax=ymax),width=0.05,alpha=0.5)+
  geom_errorbarh(aes(xmin=xmin,xmax=xmax),height=0.05,alpha=0.5)+
  geom_point(shape=19)+
  geom_errorbar(data=data.frame(x=rnullcormat[,1],y=rnullcormat[,2],ymin=rnullcormatmin[,2],ymax=rnullcormatmax[,2]),aes(x=x,ymin=ymin,ymax=ymax),width=0.05,alpha=0.5,inherit.aes = F)+
  geom_errorbarh(data=data.frame(x=rnullcormat[,1],y=rnullcormat[,2],xmin=rnullcormatmin[,1],xmax=rnullcormatmax[,1]),aes(y=y,xmin=xmin,xmax=xmax),height=0.05,alpha=0.5,inherit.aes = F)+
  geom_point(data=data.frame(x=rnullcormat[,1],y=rnullcormat[,2]),mapping = aes(x=x,y=y),alpha=0.7,inherit.aes = F)+
  scale_color_gradient(low="yellow",high="red",name=colname)+
  labs(title="",x="PC1",y="PC2")+stdtheme
ggsave(file=paste0(figdir,'crosscor/pca_meanAbsCor_errorBars.png'),width=20.3,height=19,units='cm')


#plots=list()
#for(p in parnames[c(1,2,3,4,5,7,8,9,10,6)]){
#g = ggplot(cordata,aes_string(x="x",y="y",colour=colvar,colour=p,size=sizevar))
#g+geom_point(shape=19)+ scale_color_gradient(low="yellow",high="red",name=colname)+labs(title="",x="PC1",y="PC2")+ scale_size_continuous(range=sizerange,name=sizename)+
#  geom_point(data=data.frame(x=rnullcormat[,1],y=rnullcormat[,2]),mapping = aes(x=x,y=y),color='purple',inherit.aes = F)
#plots[[p]]=g+geom_point(shape=3,size=3)+ scale_color_gradient(low="yellow",high="red",name=p)+labs(title="",x="PC1",y="PC2")
#}
#multiplot(plotlist = plots,cols = 4)




###
# param influence
#
#
#  !! these are not profiles, can be chaotic !! -> do profiles
#
# - not used -

#for(p in parnames){
#  plots=list()
#  for(i in 1:length(indicnames)){
#    g=ggplot(data.frame(aggres,params),aes_string(x=p,y=indicnames[i]))
#    plots[[indicnames[i]]]=g+geom_point()+geom_errorbar(aes_string(ymin=paste0(indicnames[i],"-",indicsdnames[i]),ymax=paste0(indicnames[i],"+",indicsdnames[i])),width=(max(params[,p])-min(params[,p]))/40)
#  }
#  multiplot(plotlist = plots,cols = 3)
#}


###
# param influence on raw corrs

#cornames = c("cor15","cor16","cor17","cor18",
#              "cor25","cor26","cor27","cor28",
#              "cor35","cor36","cor37","cor38",
#              "cor45","cor46","cor47","cor48"   
#            )
#
#corminnames = paste0(cornames,"min")
#cormaxnames = paste0(cornames,"max")

#for(p in parnames){
#  plots=list()
#  for(i in 1:length(cornames)){
#    g=ggplot(data.frame(crosscormat,params),aes_string(x=p,y=cornames[i]))
#    plots[[cornames[i]]]=g+geom_point()+geom_errorbar(aes_string(ymin=corminnames[i],ymax=cormaxnames[i]),width=(max(params[,p])-min(params[,p]))/40)
#  }
#  multiplot(plotlist = plots,cols = 4)
#}
#



##########
# Regressions
#



simple="alphalocalization+diffusion+diffusionsteps+citiesNumber+growthrate+gravityHierarchyExponent+gravityInflexion+gravityRadius+hierarchyRole+maxNewLinksNumber"
crossing="(alphalocalization+diffusion+diffusionsteps+citiesNumber+growthrate+gravityHierarchyExponent+gravityInflexion+gravityRadius+hierarchyRole+maxNewLinksNumber)^2"

# test for linear relations ?
regression=crossing

df=data.frame(aggres,params)
rsquared = matrix(0,length(parnames),length(indicnames));rownames(rsquared)=parnames;colnames(rsquared)=indicnames
rsqallparams = c();arsqallparams = c();regs=list()
for(j in 1:ncol(rsquared)){
  regs[[indicnames[j]]]=summary(lm(paste0(indicnames[j],"~",regression),df))
  arsqallparams=append(arsqallparams,regs[[indicnames[j]]]$adj.r.squared)
  rsqallparams=append(rsqallparams,regs[[indicnames[j]]]$r.squared)
  #for(i in 1:nrow(rsquared)){
  #rsquared[i,j]=summary(lm(paste0(indicnames[j],"~",parnames[i]),df))$adj.r.squared}
}
names(rsqallparams)=indicnames
names(arsqallparams)=indicnames

## idem with cross-correlations

# test for linear relations ?
regression=crossing
df=data.frame(cormat[,corrCols],params)
cornames=names(cormat[,corrCols])
rsqallparams = c();arsqallparams = c();regs=list()
for(i in 1:length(cornames)){
  regs[[cornames[i]]]=summary(lm(paste0(cornames[i],"~",regression),df))
  arsqallparams=append(arsqallparams,regs[[cornames[i]]]$adj.r.squared)
  rsqallparams=append(rsqallparams,regs[[cornames[i]]]$r.squared)
}
names(rsqallparams)=cornames
names(arsqallparams)=cornames

# and autocorrs : 
#cormat=nwcormat
cormat=nwcormat;
corrCols=2:7
df=data.frame(cormat[,corrCols],params)
simpledens = "alphalocalization+diffusion+diffusionsteps+growthrate"
crossdens = "(alphalocalization+diffusion+diffusionsteps+growthrate)^2"
simplenw = "alphalocalization+diffusion+diffusionsteps+growthrate+citiesNumber+gravityHierarchyExponent+gravityInflexion+gravityRadius+hierarchyRole+maxNewLinksNumber"
crossnw = "(alphalocalization+diffusion+diffusionsteps+growthrate+citiesNumber+gravityHierarchyExponent+gravityInflexion+gravityRadius+hierarchyRole+maxNewLinksNumber)^2"
regression=crossnw

cornames=names(cormat[,corrCols])
rsqallparams = c();arsqallparams=c();regs=list()
for(i in 1:length(cornames)){
  regs[[cornames[i]]]=summary(lm(paste0(cornames[i],"~",regression),df))
  arsqallparams=append(arsqallparams,regs[[cornames[i]]]$adj.r.squared)
  rsqallparams=append(rsqallparams,regs[[cornames[i]]]$r.squared)
}
names(arsqallparams)=cornames
names(rsqallparams)=cornames


######
# -- select particular points to run on --

# bottom-left
which(rcormat[,1]<(-1.6)&rcormat[,2]<(-1.1)) # := 256
# right - close to real
which(rcormat[,1]>0.1&realdist<0.2) # := 313
#top-left
which(rcormat[,1]<(-1.5)&rcormat[,2]>1.2) # := 308
# mid
which(rcormat[,1]>(-1.0)&rcormat[,1]<(-0.8)&rcormat[,2]<0.0&rcormat[,2]>(-0.1)) # := 340






################
# raster colored with param means for a given param
#paramspoints=params[points,]
#param="maxNewLinksNumber";resolution = 5;
#xmin=min(rcormat[points,1])/2;xmax=max(rcormat[points,1])/2;
#ymin=min(rcormat[points,2])/2;ymax=max(rcormat[points,2])/2;
# construct z data by local aggregation
#xcoords = seq(from=xmin,to=xmax,length.out=resolution)+((xmax-xmin)/(2*(resolution - 1)));xres=(xmax-xmin)/(2*(resolution - 1))
#ycoords = seq(from=ymin,to=ymax,length.out=resolution)+((ymax-ymin)/(2*(resolution - 1)));yres=(ymax-ymin)/(2*(resolution - 1))
#zmat=matrix(0,length(xcoords),length(ycoords))
#for(x in 1:nrow(zmat)){for(y in 1:ncol(zmat)){
#  zmat[x,y]=mean(unlist(paramspoints[which(abs(xcoords[x]-rcormat[points,1])<xres&abs(ycoords[y]-rcormat[points,2])<yres),param]))
#}}

#df<-melt(zmat);names(df)=c("x","y","z")
#df[is.nan(df[,"z"]),"z"]=0
#as.tbl(as.data.frame(rcormat[points,])) %>% filter(abs(xcoords[1]-PC1)<xres)
#df=data.frame(x=rcormat[points,1],y=rcormat[points,2],params[points,param]);names(df)=c("x","y","z")
#g = ggplot(df,aes(x=x, y=y, z = z))
#g+stat_contour(aes(colour=..level..),bins=20)


##########
# linear models ? (influence of parameters)
#  plot(mean(abs(cor))) agaisnt parameters -> uniform point cloud 
#
#  very shitty in all cases. -> due to repets number : non-significance of corrs, just random conditioned on params ?
#fixedConf = 10
#ldf = data.frame(y=apply(cormat[which(cormat[,2]==fixedConf),8:17],1,function(l){mean(abs(l))}),cormat[which(cormat[,2]==fixedConf),1:7])
#l = lm(y~1+citiesNumber+gravityHierarchyExponent+gravityInflexion+gravityRadius+hierarchyRole+maxNewLinksNumber,ldf)
#summary(l)
#hist(apply(cormat[,8:17],1,function(l){mean(abs(l))}),breaks=50)
#hist(apply(cormat[,8:17],1,function(l){mean(l)}),breaks=50)
#hist(apply(cormat[which(cormat[,2]==fixedConf),8:17],1,function(l){mean(abs(l))}),breaks=50)
# cor = 1 -> issue in data ? otherwise mean corr seems relatively gaussian with zero mean.


####### TODO
# sort of space-matters approachs : sensitivity of phase diagram along nw parameters, 
# for ??? fixed density confs
#  -> 2nd order ? CHECK THAT. AMPLITUDE AND SIGNIFICANCE OF 2ND ORDER DEVIATION.


