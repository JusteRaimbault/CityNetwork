
library(dplyr)
library(ggplot2)
library(GGally)
library(DiceDesign)
library(reshape2)
source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/MacroCoEvol/MacroCoEvol/calibres'))

resdir = '20180125_pse_grid'

params = c("growthRate","gravityGamma","gravityDecay","gravityWeight"#,"feedbackGamma","feedbackDecay","feedbackWeight")
           ,"nwThreshold","nwExponent","nwGmax")

paramnames = list("growthRate"=expression(r[0]),"gravityGamma"=expression(gamma[G]),"gravityDecay"=expression(d[G]),
                  "gravityWeight"=expression(w[G]),"nwThreshold"=expression(phi[0]),"nwExponent"=expression(gamma[N]),
                  "nwGmax"=expression(g[max])
)

figdir = paste0(Sys.getenv('CN_HOME'),'/Results/MacroCoEvol/Calibration/',resdir,'/');dir.create(figdir)


latestgen = max(as.integer(sapply(strsplit(sapply(strsplit(list.files(paste0(resdir)),"population"),function(s){s[2]}),".csv"),function(s){s[1]})))
res <- as.tbl(read.csv(paste0(resdir,'/population',latestgen,'.csv')))

res$gravityDecayF = cut(res$gravityDecay,6)
ggpairs(data=res,columns = c("rhoPopClosenessPos","rhoPopClosenessNeg","rhoPopAccessibilityPos","rhoPopAccessibilityNeg","rhoClosenessAccessibilityPos","rhoClosenessAccessibilityNeg"),
        aes(colour=gravityDecayF,alpha=0.4)
        )
ggsave(filename = paste0(figdir,'scatterplot_colorgravityDecay.png'),width=40,height=25,units='cm')

res$nwThresholdF = cut(res$nwThreshold,6)
ggpairs(data=res,columns = c("rhoPopClosenessPos","rhoPopClosenessNeg","rhoPopAccessibilityPos","rhoPopAccessibilityNeg","rhoClosenessAccessibilityPos","rhoClosenessAccessibilityNeg"),
        aes(colour=nwThresholdF,alpha=0.4)
)
ggsave(filename = paste0(figdir,'scatterplot_colornwThreshold.png'),width=40,height=25,units='cm')


#discr = discrepancyCriteria(res[,c("rhoPopClosenessPos","rhoPopClosenessNeg","rhoPopAccessibilityPos","rhoPopAccessibilityNeg","rhoClosenessAccessibilityPos","rhoClosenessAccessibilityNeg")],
#                            type=c('L2'))



####

sres = melt(res,measure.vars = c("rhoPopClosenessPos","rhoPopClosenessNeg","rhoPopAccessibilityPos","rhoPopAccessibilityNeg","rhoClosenessAccessibilityPos","rhoClosenessAccessibilityNeg"))

g=ggplot(sres,aes(x=gravityDecay,y=value,colour=variable))
g+geom_point(pch='.')+geom_smooth()

g=ggplot(sres,aes(x=nwThreshold,y=value,colour=variable))
g+geom_point(pch='.')+geom_smooth()


####
# variety of produced regimes

regs=rep("",nrow(res))
for(j in 8:13){
  regs=paste0(regs,ifelse(res[,j]==0,0,ifelse(res[,j]>0,1,-1)))
}

unique(regs)






