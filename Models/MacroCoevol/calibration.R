
library(dplyr)
library(ggplot2)
source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/MacroCoEvol/MacroCoEvol/calibres'))

periods = c("1831-1851","1841-1861","1851-1872","1881-1901","1891-1911","1921-1936","1946-1968","1962-1982","1975-1999")

#resdir = '20170929_calibperiod_nsga_abstractnw_local/'
resdir = '20171122_calibperiod_island_abstractnw_grid/'

params = c("growthRate","gravityGamma","gravityDecay","gravityWeight"#,"feedbackGamma","feedbackDecay","feedbackWeight")
            ,"nwThreshold","nwExponent","nwGmax")

paramnames = list("growthRate"=expression(r[0]),"gravityGamma"=expression(gamma[G]),"gravityDecay"=expression(d[G]),
                  "gravityWeight"=expression(w[G]),"nwThreshold"=expression(phi[0]),"nwExponent"=expression(gamma[N]),
                  "nwGmax"=expression(g[max])
                  )

figdir = paste0(Sys.getenv('CN_HOME'),'/Results/MacroCoEvol/Calibration/',resdir,'/');dir.create(figdir)


#filters=list();for(p in periods){filters[[p]]=c(100,100)}
filters = list(c(24.5,21.92),c(25,22.8),c(25.5,23.6),
               c(24.75,22),c(25,19.9),c(25.5,18),
               c(27.1,19),c(28.1,19),c(27.1,16.22))
names(filters)<-periods

filtered=T

#plots=list()
for(param in params){
  cperiods = c();cparam=c();logmsepop=c();logmsedist=c()
  for(period in periods){
    latestgen = max(as.integer(sapply(strsplit(sapply(strsplit(list.files(paste0(resdir,'/',period)),"population"),function(s){s[2]}),".csv"),function(s){s[1]})))
    res <- as.tbl(read.csv(paste0(resdir,'/',period,'/population',latestgen,'.csv')))
    #res=res[which(res$gravityWeight>0.0001&res$gravityDecay<500&res$feedbackDecay<500),]
    if(filtered==T){
      res=res[which(res$logmsepop<filters[[period]][1]&res$logmsedist<filters[[period]][2]),]
    }
    #show(paste0(period,' : dG = ',mean(res$gravityDecay),' +- ',sd(res$gravityDecay)))
    logmsepop=append(logmsepop,res$logmsepop);logmsedist=append(logmsedist,res$logmsedist)
    cperiods=append(cperiods,rep(period,nrow(res)));cparam=append(cparam,res[[param]])
  }
  g=ggplot(data.frame(logmsepop=logmsepop,logmsedist=logmsedist,param=cparam,period=cperiods),aes_string(x="logmsepop",y="logmsedist",colour="param"))
  #plots[[param]]=g+geom_point()+scale_colour_gradient(low="blue",high="red",name=param)+facet_wrap(~period,scales = "free")+xlab("log MSE population")+ylab("log MSE distance")
  g+geom_point()+scale_colour_gradient(low="blue",high="red",name=paramnames[[param]])+facet_wrap(~period,scales = "free")+xlab(expression(epsilon[G]))+ylab(expression(epsilon[D]))+stdtheme
  ggsave(paste0(figdir,"pareto_",param,"_filt",filtered,".pdf"),width=30,height=20,units='cm')
}
#multiplot(plotlist = plots,cols=3)




#############
## param variation in time

getDate<-function(s){(as.integer(strsplit(s,"-")[[1]][1])+as.integer(strsplit(s,"-")[[1]][2]))/2}

filtered=T
for(param in params){
  decays=c();sdDecay=c();types=c();ctimes=c()
  for(period in periods){
    latestgen = max(as.integer(sapply(strsplit(sapply(strsplit(list.files(paste0(resdir,'/',period)),"population"),function(s){s[2]}),".csv"),function(s){s[1]})))
    res <- as.tbl(read.csv(paste0(resdir,'/',period,'/population',latestgen,'.csv')))
    #if(filtered){res=res[which(res$nwThreshold<15&res$gravityDecay<150),]}#&res$gravityGamma<5),]}
    if(filtered==T){
      res=res[which(res$logmsepop<filters[[period]][1]&res$logmsedist<filters[[period]][2]),]
    }
    #show(paste0(mean(unlist(res[,param])),' +- ',sd(unlist(res[,param]))))
    decays = append(decays,mean(unlist(res[,param])));sdDecay = append(sdDecay,sd(unlist(res[,param])));types = append(types,"pareto")
    decays = append(decays,unlist(res[which(res$logmsepop==min(res$logmsepop))[1],param]));sdDecay=append(sdDecay,0);types = append(types,"logmsepop")
    decays = append(decays,unlist(res[which(res$logmsedist==min(res$logmsedist))[1],param]));sdDecay=append(sdDecay,0);types = append(types,"logmsedist")
    ctimes = append(ctimes,rep(getDate(period),3))
  }
  #hist(res$logmsepop,breaks=50);hist(res$logmsedist,breaks=50);
  g=ggplot(data.frame(decay=decays,sd=sdDecay,type=types,time=ctimes),aes(x=time,y=decay,colour=type,group=type))
  g+geom_point()+geom_line()+geom_errorbar(aes(ymin=decay-sd,ymax=decay+sd))+ylab(paramnames[[param]])+xlab(expression(t))+stdtheme
  ggsave(file=paste0(figdir,'param_',param,'_filt',as.numeric(filtered),'.png'),width=20,height=15,units='cm')
}







