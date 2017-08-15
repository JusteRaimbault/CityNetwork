
library(dplyr)
library(ggplot2)
source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/MacroCoEvol/MacroCoEvol/calibration'))

periods = c("1831-1851")#,"1841-1861","1851-1872","1881-1901","1891-1911","1921-1936","1946-1968","1962-1982","1975-1999")

resdir = '20170815_calibperiod_nsga_abstractnw_2'

params = c("growthRate","gravityGamma","gravityDecay","gravityWeight"#,"feedbackGamma","feedbackDecay","feedbackWeight")
            ,"nwThreshold","nwExponent","nwGmax")

figdir = paste0(Sys.getenv('CN_HOME'),'/Results/MacroCoEvol/Calibration/',resdir,'/');dir.create(figdir)


plots=list()
for(param in params){
  cperiods = c();cparam=c();logmsepop=c();logmsedist=c()
  for(period in periods){
    latestgen = max(as.integer(sapply(strsplit(sapply(strsplit(list.files(paste0(resdir,'/',period)),"population"),function(s){s[2]}),".csv"),function(s){s[1]})))
    res <- as.tbl(read.csv(paste0(resdir,'/',period,'/population',latestgen,'.csv')))
    #res=res[which(res$gravityWeight>0.0001&res$gravityDecay<500&res$feedbackDecay<500),]
    #show(paste0(period,' : dG = ',mean(res$gravityDecay),' +- ',sd(res$gravityDecay)))
    logmsepop=append(logmsepop,res$logmsepop);logmsedist=append(logmsedist,res$logmsedist)
    cperiods=append(cperiods,rep(period,nrow(res)));cparam=append(cparam,res[[param]])
  }
  g=ggplot(data.frame(logmsepop=logmsepop,logmsedist=logmsedist,param=cparam,period=cperiods),aes_string(x="logmsepop",y="logmsedist",colour="param"))
  plots[[param]]=g+geom_point()+scale_colour_gradient(low="blue",high="red",name=param)+facet_wrap(~period,scales = "free")
}
multiplot(plotlist = plots,cols=3)




