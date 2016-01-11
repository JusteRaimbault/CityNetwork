library(dplyr)
library(ggplot2)
library(reshape2)
library(boot)

setwd(paste0(Sys.getenv('CN_HOME'),'/Results/Synthetic/Network'))

#res <- read.csv('20151224_LHSLocal/2015_12_24_19_39_03_LHS_LOCAL.csv')
#res <- read.csv('20160106_LHSDensityNW/data/2016_01_06_21_47_22_LHS_DENSITYNW.csv')

# load multiple result files
# and bind them into single tbl -- must incr idpar before to avoid collisions
resdir='20160106_LHSDensityNW/data/'
files <- list.files(resdir)
#res <- read.csv(paste0(resdir,files[4]))


res = as.tbl(read.csv(paste0(resdir,files[1])))
currentmaxidpar = max(res[,"idpar"])+1
for(f in files[2:length(files)]){
  temp <- as.tbl(read.csv(paste0(resdir,f)))
  temp[,"idpar"] = temp[,"idpar"]+currentmaxidpar
  res = bind_rows(res,temp)
  currentmaxidpar = max(res[,"idpar"])+1
}

nrep=80

gres <- as.tbl(res) %>% filter(meanBwCentrality<=1) %>% group_by(idpar)

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
nwcormat <- gres %>% filter(idpar %in% glength$idpar[glength$groupLength==nrep]) %>% summarise(
        cor12 = cor(meanBwCentrality,meanPathLength),
        cor13 = cor(meanBwCentrality,meanRelativeSpeed),
        cor14 = cor(meanBwCentrality,nwDiameter),
        cor23 = cor(meanPathLength,meanRelativeSpeed),
        cor24 = cor(meanPathLength,nwDiameter),
        cor34 = cor(meanRelativeSpeed,nwDiameter)
     )

# density block
denscormat <- gres %>% filter(idpar %in% glength$idpar[glength$groupLength==nrep]) %>%  summarise(
    cor12 = cor(moran,distance),
    cor13 = cor(moran,entropy),
    cor14 = cor(moran,slope),
    cor23 = cor(distance,entropy),
    cor24 = cor(distance,slope),
    cor34 = cor(entropy,slope)
) 


# cross correlations -- hardcore with CIs
crosscormat <- gres  %>% filter(idpar %in% glength$idpar[glength$groupLength==nrep]) %>% summarise(
   cor15 = cor.test(meanBwCentrality,moran,method="pearson",conf.level=0.95)$estimate,cor15min = cor.test(meanBwCentrality,moran,method="pearson",conf.level=0.95)$conf.int[1],cor15max = cor.test(meanBwCentrality,moran,method="pearson",conf.level=0.95)$conf.int[2],
   cor16 = cor.test(meanBwCentrality,distance,method="pearson",conf.level=0.95)$estimate,cor16min = cor.test(meanBwCentrality,distance,method="pearson",conf.level=0.95)$conf.int[1],cor16max = cor.test(meanBwCentrality,distance,method="pearson",conf.level=0.95)$conf.int[2],
   cor17 = cor.test(meanBwCentrality,entropy,method="pearson",conf.level=0.95)$estimate,cor17min = cor.test(meanBwCentrality,entropy,method="pearson",conf.level=0.95)$conf.int[1],cor17max = cor.test(meanBwCentrality,entropy,method="pearson",conf.level=0.95)$conf.int[2],
   cor18 = cor.test(meanBwCentrality,slope,method="pearson",conf.level=0.95)$estimate,cor18min = cor.test(meanBwCentrality,slope,method="pearson",conf.level=0.95)$conf.int[1],cor18max = cor.test(meanBwCentrality,slope,method="pearson",conf.level=0.95)$conf.int[2],
   cor25 = cor.test(meanPathLength,moran,method="pearson",conf.level=0.95)$estimate,cor25min = cor.test(meanPathLength,moran,method="pearson",conf.level=0.95)$conf.int[1],cor25max = cor.test(meanPathLength,moran,method="pearson",conf.level=0.95)$conf.int[2],
   cor26 = cor.test(meanPathLength,distance,method="pearson",conf.level=0.95)$estimate,cor26min = cor.test(meanPathLength,distance,method="pearson",conf.level=0.95)$conf.int[1],cor26max = cor.test(meanPathLength,distance,method="pearson",conf.level=0.95)$conf.int[2],
   cor27 = cor.test(meanPathLength,entropy,method="pearson",conf.level=0.95)$estimate,cor27min = cor.test(meanPathLength,entropy,method="pearson",conf.level=0.95)$conf.int[1],cor27max = cor.test(meanPathLength,entropy,method="pearson",conf.level=0.95)$conf.int[2],
   cor28 = cor.test(meanPathLength,slope,method="pearson",conf.level=0.95)$estimate,cor28min = cor.test(meanPathLength,slope,method="pearson",conf.level=0.95)$conf.int[1],cor28max = cor.test(meanPathLength,slope,method="pearson",conf.level=0.95)$conf.int[2],
   cor35 = cor.test(meanRelativeSpeed,moran,method="pearson",conf.level=0.95)$estimate,cor35min = cor.test(meanRelativeSpeed,moran,method="pearson",conf.level=0.95)$conf.int[1],cor35max = cor.test(meanRelativeSpeed,moran,method="pearson",conf.level=0.95)$conf.int[2],
   cor36 = cor.test(meanRelativeSpeed,distance,method="pearson",conf.level=0.95)$estimate,cor36min = cor.test(meanRelativeSpeed,distance,method="pearson",conf.level=0.95)$conf.int[1],cor36max = cor.test(meanRelativeSpeed,distance,method="pearson",conf.level=0.95)$conf.int[2],
   cor37 = cor.test(meanRelativeSpeed,entropy,method="pearson",conf.level=0.95)$estimate,cor37min = cor.test(meanRelativeSpeed,entropy,method="pearson",conf.level=0.95)$conf.int[1],cor37max = cor.test(meanRelativeSpeed,entropy,method="pearson",conf.level=0.95)$conf.int[2],
   cor38 = cor.test(meanRelativeSpeed,slope,method="pearson",conf.level=0.95)$estimate,cor38min = cor.test(meanRelativeSpeed,slope,method="pearson",conf.level=0.95)$conf.int[1],cor38max = cor.test(meanRelativeSpeed,slope,method="pearson",conf.level=0.95)$conf.int[2],
   cor45 = cor.test(nwDiameter,moran,method="pearson",conf.level=0.95)$estimate,cor45min = cor.test(nwDiameter,moran,method="pearson",conf.level=0.95)$conf.int[1],cor45max = cor.test(nwDiameter,moran,method="pearson",conf.level=0.95)$conf.int[2],
   cor46 = cor.test(nwDiameter,distance,method="pearson",conf.level=0.95)$estimate,cor46min = cor.test(nwDiameter,distance,method="pearson",conf.level=0.95)$conf.int[1],cor46max = cor.test(nwDiameter,distance,method="pearson",conf.level=0.95)$conf.int[2],
   cor47 = cor.test(nwDiameter,entropy,method="pearson",conf.level=0.95)$estimate,cor47min = cor.test(nwDiameter,entropy,method="pearson",conf.level=0.95)$conf.int[1],cor47max = cor.test(nwDiameter,entropy,method="pearson",conf.level=0.95)$conf.int[2],
   cor48 = cor.test(nwDiameter,slope,method="pearson",conf.level=0.95)$estimate,cor48min = cor.test(nwDiameter,slope,method="pearson",conf.level=0.95)$conf.int[1],cor48max = cor.test(nwDiameter,slope,method="pearson",conf.level=0.95)$conf.int[2]
)


#summary(cormat[1,8:17])

cormat = crosscormat


# histograms of correlations
# -> log normal ? COMPARE WITH NULL MODEL ? which one ?
par(mfrow=c(4,4))
for(j in 0:(ncol(cormat)/3 - 1)){
  d=cormat[[colnames(cormat)[3*j+2]]]
  hist(d,breaks=30,main=colnames(cormat)[3*j+2],xlab="")
  abline(v=mean(d),col="red")
  
  #corj = cormat[[colnames(cormat)[j]]];show(mean(corj))
  #rho = mean(corj)
  # simulate correlated vectors of same size
  #corrs = c();for(k in 1:1000){x1 = rnorm(1000,mean=0);corrs=append(corrs,cor(x1,rho*x1 +sqrt(1 - rho^2)*rnorm(1000,mean=0)))}
  #ggplot(vegLengths, aes(length, fill = veg)) + geom_histogram(alpha = 0.5, aes(y = ..density..), position = 'identity')
}


# test : pairwise correlations of subvectors ?
# - 50 subvector size ; idpar == 0
#
#  -- THIS IS BOOTSTRAP --
#
point=1;subvecsize=20;subsamplesize=2000;
fgres <- gres %>% filter(idpar==point)
subsample = sample.int(n=nrow(fgres),size=subsamplesize,replace=FALSE);fgres <- fgres[subsample,]
fgres <- fgres %>% mutate(row=1:nrow(fgres)) %>% mutate(subvec=floor((row-1)/subvecsize)+1)
corrs = c();subvecnum=max(fgres$subvec)-1;
for(i in 1:subvecnum){corrs = append(corrs,cor(c(as.data.frame(fgres%>%filter(subvec==i))$moran),as.data.frame(fgres%>%filter(subvec==i))$meanBwCentrality));}
hist(corrs,breaks=50);mean(corrs);

#
cor.test(fgres$moran,fgres$meanBwCentrality,method="pearson")$estimate
library(boot)
boot(fgres,function(data,i){cor(data$moran[i],data$meanBwCentrality[i])},1000)

# find a way to summarize corr matrices -> various norms ?
#  per var : max ; spread ; ?



# HeatMaps

nindics = c("bw-centrality","path-length","speed","diameter")
mindics = c("moran","distance","entropy","slope")

cormat = crosscormat[,2:ncol(crosscormat)]

maxcor = apply(crosscormat[,((0:(ncol(crosscormat)/3-1))*3+2)],2,function(c){max(c)})
mincor = apply(crosscormat[,((0:(ncol(crosscormat)/3-1))*3+2)],2,function(c){min(c)})
maxabscor = apply(crosscormat[,((0:(ncol(crosscormat)/3-1))*3+2)],2,function(c){max(abs(c))})
amplcor = apply(crosscormat[,((0:(ncol(crosscormat)/3-1))*3+2)],2,function(c){max(c)-min(c)})
meanabscor=amplcor = apply(crosscormat[,((0:(ncol(crosscormat)/3-1))*3+2)],2,function(c){mean(abs(c))})


var=mincor;title = "Minimal correlations";purpose="min cor"

df=melt(matrix(data=var,nrow=4,byrow=FALSE));names(df)=c("x","y","z")
g = ggplot(df) + scale_fill_gradient(low="yellow",high="red",name=purpose)#+ geom_raster(hjust = 0, vjust = 0) 
g+geom_raster(aes(x,y,fill=z))+scale_x_discrete(limits=nindics)+scale_y_discrete(limits=mindics)+theme(axis.ticks = element_blank(),panel.background=element_blank(),legend.title=element_text(""))+labs(title=title,x="",y="")


%dgres = gres  %>% filter(idpar %in% glength$idpar[glength$groupLength==nrep])

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
#rcormatmin = as.matrix(cormat[,corrCols+1]) %*% as.matrix(rotation)
#rcormatmax = as.matrix(cormat[,corrCols+2]) %*% as.matrix(rotation)
sigma1=apply(cormat[,corrCols+2]-cormat[,corrCols+1],1,function(r){sqrt(sum((r*c(rotation[,1]))^2))})
sigma2=apply(cormat[,corrCols+2]-cormat[,corrCols+1],1,function(r){sqrt(sum((r*c(rotation[,2]))^2))})

# bootstrap CI
#summary(boot(rcormat,function(data,i){data[i,1]},1000))




#plot(rcormat[,1],rcormat[,2])
# color according to mean correlation / other?
#as.tbl(as.data.frame(t(rcormat))) %>% transmute(m=(PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10)/10)
#apply(rcormat,1,mean)
npoints = nrow(cormat)
points = sample.int(nrow(rcormat),size=npoints,replace=FALSE)
# must filter according to extent -> minimize overlap and maximize total extent.
# Q : what about "real" morpho conf ? 
# -> select rows close to real points
#  source 'morpho_calib.R'.real
distance<-function(...,cloud){
  return(min(apply(cloud,1,function(r){sqrt(sum((r-c(...))^2))})))
}
realdist = apply(aggres,1,function(r){distance(r["moranIndex"],r["distanceMean"],r["dentropy"],r["rslope"],cloud=real[,3:6])})
aggres <- aggres %>% mutate(realdist=realdist)
# now filter on real dist
#points= which(realdist<0.2)

# find points giving an optimal covering with error bars
# greedy algo : sequentially (in random order), add point if coverage overlaps not too much
#  -> overlap function, (([xmin,xmax],[ymin,ymax]),cloud)-> overlap
overlap <- function(extent,cloud){
   res = 0
   if(length(cloud)>0){
   for(i in 1:length(cloud)){
     xd = max(extent[1],cloud[[i]][1])-min(extent[2],cloud[[i]][2])
     yd = max(extent[3],cloud[[i]][3])-min(extent[4],cloud[[i]][4])
     if(xd>0&yd>0){res=max(res,xd*yd)}
   }
   }
   return(res)
}

overlapthreshold = 0.1
points=c();cloud=list()
for(i in 1:nrow(rcormat)){
   a=abs((rcormatmax[i,1]-rcormatmin[i,1])*(rcormatmax[i,2]-rcormatmin[i,2]))
   r=c(rcormatmin[i,1],rcormatmax[i,1],rcormatmin[i,2],rcormatmax[i,2])
   show(overlap(r,cloud)/a)
   if(overlap(r,cloud)/a<overlapthreshold){
     points=append(points,i);cloud[[as.character(i)]]=r
   }
}





#plots=list()
#for(p in parnames[c(1,2,3,4,5,7,8,9,10,6)]){
  
colvar="real";colname="real proximity"
sizevar="meanCor";sizename="mean abs cor";sizerange=c(0.8,4)

g = ggplot(
  data.frame(
    x=rcormat[points,1],
    y=rcormat[points,2],
    xmin=rcormat[points,1]-sigma1,#rcormatmin[points,1],
    xmax=rcormat[points,1]+sigma1,#rcormatmax[points,1],
    ymin=rcormat[points,2]-sigma2,#rcormatmin[points,2],
    ymax=rcormat[points,2]+sigma2,#rcormatmax[points,2],
    meanCor=apply(cormat,1,function(l){mean(abs(l))})[points],
    extent=apply(cormat,1,function(l){max(l)-min(l)})[points],
    maxCor=apply(cormat,1,function(l){max(l)})[points],
    minCor=apply(cormat,1,function(l){min(l)})[points],
    real=1-realdist[points],
    params[points,]
    ),
  aes_string(x="x",y="y"
             ,colour=colvar
             #,colour=p
             #,size=sizevar
            )
  )
g+geom_point(shape=19)+ scale_color_gradient(low="yellow",high="red",name=colname)+labs(title="",x="PC1",y="PC2")+geom_errorbar(aes(ymin=ymin,ymax=ymax),width=0.05)+geom_errorbarh(aes(xmin=xmin,xmax=xmax),height=0.05)##+ scale_size_continuous(range=sizerange,name=sizename)#
 
#plots[[p]]=g+geom_point(shape=3,size=3)+ scale_color_gradient(low="yellow",high="red",name=p)+labs(title="",x="PC1",y="PC2")
#}
#multiplot(plotlist = plots,cols = 4)




###
# param influence
#  !! these are not profiles, can be chaotic !! -> do profiles

for(p in parnames){
  plots=list()
  for(i in 1:length(indicnames)){
    g=ggplot(data.frame(aggres,params),aes_string(x=p,y=indicnames[i]))
    plots[[indicnames[i]]]=g+geom_point()+geom_errorbar(aes_string(ymin=paste0(indicnames[i],"-",indicsdnames[i]),ymax=paste0(indicnames[i],"+",indicsdnames[i])),width=(max(params[,p])-min(params[,p]))/40)
  }
  multiplot(plotlist = plots,cols = 3)
}


###
# param influence on raw corrs

cornames = c("cor15","cor16","cor17","cor18",
              "cor25","cor26","cor27","cor28",
              "cor35","cor36","cor37","cor38",
              "cor45","cor46","cor47","cor48"   
            )

corminnames = paste0(cornames,"min")
cormaxnames = paste0(cornames,"max")

for(p in parnames){
  plots=list()
  for(i in 1:length(cornames)){
    g=ggplot(data.frame(crosscormat,params),aes_string(x=p,y=cornames[i]))
    plots[[cornames[i]]]=g+geom_point()+geom_errorbar(aes_string(ymin=corminnames[i],ymax=cormaxnames[i]),width=(max(params[,p])-min(params[,p]))/40)
  }
  multiplot(plotlist = plots,cols = 4)
}




##########
# Regressions
#



simple="alphalocalization+diffusion+diffusionsteps+citiesNumber+growthrate+gravityHierarchyExponent+gravityInflexion+gravityRadius+hierarchyRole+maxNewLinksNumber"
crossing="(alphalocalization+diffusion+diffusionsteps+citiesNumber+growthrate+gravityHierarchyExponent+gravityInflexion+gravityRadius+hierarchyRole+maxNewLinksNumber)^2"

# test for linear relations ?
df=data.frame(aggres,params)
rsquared = matrix(0,length(parnames),length(indicnames));rownames(rsquared)=parnames;colnames(rsquared)=indicnames
rsqallparams = c();regs=list()
for(j in 1:ncol(rsquared)){
  regs[[indicnames[j]]]=summary(lm(paste0(indicnames[j],"~",simple),df))
  rsqallparams=append(rsqallparams,regs[[indicnames[j]]]$adj.r.squared)
  for(i in 1:nrow(rsquared)){
  rsquared[i,j]=summary(lm(paste0(indicnames[j],"~",parnames[i]),df))$r.squared
}}
names(rsqallparams)=indicnames

## idem with cross-correlations

# test for linear relations ?
df=data.frame(cormat[,corrCols],params)
cornames=names(cormat[,corrCols])
rsqallparams = c();regs=list()
for(i in 1:length(cornames)){
  regs[[cornames[i]]]=summary(lm(paste0(cornames[i],"~",simple),df))
  rsqallparams=append(rsqallparams,regs[[cornames[i]]]$adj.r.squared)
}
names(rsqallparams)=cornames



# and autocorrs : 
cormat=nwcormat#denscormat;
corrCols=2:7
df=data.frame(cormat[,corrCols],params)
#simpledens = "alphalocalization+diffusion+diffusionsteps+growthrate"
#crossdens = "(alphalocalization+diffusion+diffusionsteps+growthrate)^2"
simplenw = "citiesNumber+gravityHierarchyExponent+gravityInflexion+gravityRadius+hierarchyRole+maxNewLinksNumber"
crossnw = "(citiesNumber+gravityHierarchyExponent+gravityInflexion+gravityRadius+hierarchyRole+maxNewLinksNumber)^2"
cornames=names(cormat[,corrCols])
rsqallparams = c();regs=list()
for(i in 1:length(cornames)){
  regs[[cornames[i]]]=summary(lm(paste0(cornames[i],"~",crossnw),df))
  rsqallparams=append(rsqallparams,regs[[cornames[i]]]$adj.r.squared)
}
names(rsqallparams)=cornames


######
# -- select particular points to run on --

# bottom-left
which(rcormat[,1]<(-1.6)&rcormat[,2]<(-1.1)) # := 256
# right - close to real
which(rcormat[,1]>0.1&realdist<0.2) # := 313
#top-left
which(rcormat[,1]<(-1.5)&rcormat[,2]>1.2) # := 308







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
# for ≠ fixed density confs
#  -> 2nd order ? CHECK THAT. AMPLITUDE AND SIGNIFICANCE OF 2ND ORDER DEVIATION.


