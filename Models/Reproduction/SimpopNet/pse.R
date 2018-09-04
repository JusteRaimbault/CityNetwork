
library(dplyr)
library(ggplot2)
library(GGally)
library(DiceDesign)
library(reshape2)
source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/Reproduction/SimpopNet/calib'))

resdir = '20180824_PSE_GRID/'

params = c("gravityDecay","gravityGamma","networkGamma","networkThreshold","networkSpeed","synthRankSize")

paramnames = list("gravityGamma"=expression(gamma[G]),"gravityDecay"=expression(d[G]),
                  "networkGamma"=expression(gamma[N]),"networkThreshold"=expression(phi[0]),"networkSpeed"=expression(v[0]),
                  "synthRankSize"=expression(alpha)
)

indics=c("rhoPopClosenessPos","rhoPopClosenessNeg","rhoPopAccessibilityPos","rhoPopAccessibilityNeg","rhoClosenessAccessibilityPos","rhoClosenessAccessibilityNeg")

figdir = paste0(Sys.getenv('CN_HOME'),'/Results/Reproduction/SimpopNet/PSE/',resdir,'/');dir.create(figdir,recursive = T)

gens = as.integer(sapply(strsplit(sapply(strsplit(list.files(paste0(resdir)),"population"),function(s){s[2]}),".csv"),function(s){s[1]}))
latestgen = max(gens)
res <- as.tbl(read.csv(paste0(resdir,'/population',latestgen,'.csv')))


frontDist <- function(f1,f2){
  if(nrow(f1)==0||nrow(f2)==0){return(0)}
  totalDist = 0
  #for(i1 in 1:nrow(f1)){for(i2 in 1:nrow(f2)){totalDist=totalDist+sum((f1[i1,] - f2[i2,])^2)}}
  return(sum(apply(f1,1,function(r){sum(rowSums((f2 - matrix(rep(r,nrow(f2))))^2))})))
  #return(totalDist)
}

counts=c();newpop = data.frame();dists=c()
for(gen in sort(gens)){show(gen)
  prevpop <- newpop
  newpop <- as.tbl(read.csv(paste0(resdir,'/population',gen,'.csv')));counts=append(counts,nrow(res))
  if(nrow(prevpop)>0){dists=append(dists,frontDist(prevpop[,indics],newpop[,indics]))}
}
plot(sort(gens),counts,type='l')
plot(sort(gens)[2:length(gens)],dists,type='l')

#res=res[res$evolution.samples>3,]

res$gravityDecayF = cut(res$gravityDecay,6)
ggpairs(data=res,columns = c("rhoPopClosenessPos","rhoPopClosenessNeg","rhoPopAccessibilityPos","rhoPopAccessibilityNeg","rhoClosenessAccessibilityPos","rhoClosenessAccessibilityNeg"),
        aes(colour=gravityDecayF,alpha=0.4)
        )
ggsave(filename = paste0(figdir,'scatterplot_colorgravityDecay.png'),width=40,height=25,units='cm')

res$networkThresholdF = cut(res$networkThreshold,6)
ggpairs(data=res,columns = c("rhoPopClosenessPos","rhoPopClosenessNeg","rhoPopAccessibilityPos","rhoPopAccessibilityNeg","rhoClosenessAccessibilityPos","rhoClosenessAccessibilityNeg"),
        aes(colour=networkThresholdF,alpha=0.4)
)
ggsave(filename = paste0(figdir,'scatterplot_colornwThreshold.png'),width=40,height=25,units='cm')


#discr = discrepancyCriteria(res[,c("rhoPopClosenessPos","rhoPopClosenessNeg","rhoPopAccessibilityPos","rhoPopAccessibilityNeg","rhoClosenessAccessibilityPos","rhoClosenessAccessibilityNeg")],
#                            type=c('L2'))



####

sres = melt(res,measure.vars = c("rhoPopClosenessPos","rhoPopClosenessNeg","rhoPopAccessibilityPos","rhoPopAccessibilityNeg","rhoClosenessAccessibilityPos","rhoClosenessAccessibilityNeg"))

g=ggplot(sres,aes(x=gravityDecay,y=value,colour=variable))
g+geom_point(pch='.')+geom_smooth()

g=ggplot(sres,aes(x=networkThreshold,y=value,colour=variable))
g+geom_point(pch='.')+geom_smooth()


####
# variety of produced regimes

regs=rep("",nrow(res))
regstrength=rep(0,nrow(res))
regwstrength=rep(0,nrow(res))
for(j in 8:13){
  #regs=paste0(regs,ifelse(res[,j]==0,0,ifelse(res[,j]>0,1,-1)))
  regs=paste0(regs,ifelse(abs(res[,j])>0.1,0,ifelse(res[,j]>0,1,-1)))
  #regstrength=regstrength+ifelse(res[,j]==0,0,1)
  regstrength=regstrength+ifelse(abs(res[,j])>0.1,0,1)
  regwstrength=regwstrength+abs(res[,j])
}

unique(regs)
max(regstrength)
summary(regwstrength/8)




