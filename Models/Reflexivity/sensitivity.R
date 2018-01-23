#############
# sensitivity


library(ggplot2)
library(reshape2)
source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

source(paste0(Sys.getenv('CN_HOME'),'/Models/QuantEpistemo/HyperNetwork/HyperNetwork/functions.R'))
source(paste0(Sys.getenv('CN_HOME'),'/Models/QuantEpistemo/HyperNetwork/HyperNetwork/networkConstruction.R'))


setwd(paste0(Sys.getenv('CN_HOME'),'/Models/Reflexivity'))

#load('processed/citation.RData')

mongobase='reflexivity';kwLimit=50000;eth_graph=10

graphfile=paste0(mongobase,'_network_',kwLimit,'_eth',eth_graph,'_nonfiltdico')
outputfile=paste0('sensitivity/',graphfile,'.RData')
load(paste0(Sys.getenv('CN_HOME'),'/Models/Reflexivity/processed/',graphfile,'.RData'))
semantic=res$g;
keyword_dico=res$keyword_dico
#rm(res);gc()
head(names(keyword_dico))
head(nodesabstract$X8635210426419881284)

#figdir=paste0(Sys.getenv('CN_HOME'),'/Results/QuantEpistemo/HyperNetwork/NetworkTerritories/Semantic/network_kwLimit',kwLimit,'_eth',eth_graph,'/')
figdir=paste0(Sys.getenv('CN_HOME'),'/Results/Reflexivity/')
dir.create(figdir)

load(outputfile)

params = c("degree_max","edge_th","freqmin","freqmax")
indics=c("modularity","communities","components","vertices","density","balance")

# multiplots
# plots=list()
# g=ggplot(d)+scale_fill_gradient(low="yellow",high="red")
# for(indic in indics){
#   plots[[indic]] = g+geom_raster(aes_string("degree_max","edge_th",fill=indic))+facet_grid(freqmax~freqmin)
# }
# multiplot(plotlist = plots,cols=3)
# 
# # noramlized facetted
# dd=d[d$freqmin==0,];for(indic in indics){dd[,indic]=(dd[,indic]-min(dd[,indic]))/(max(dd[,indic])-min(dd[,indic]))}
# g=ggplot(melt(dd,id.vars = params,measure.vars = indics,variable.name = 'indic'),aes(x=degree_max,y=edge_th,fill=value))
# g+geom_raster()+scale_fill_gradient(low="yellow",high="red")+xlab(expression(k[max]))+ylab(expression(theta[w]))+facet_wrap(~indic)
# ggsave(file=paste0(figdir,'sensitivity_freqmin0_normalized.png'),width=30,height=20,units='cm')
# 
# # 
# g = ggplot(d[d$freqmin==0,],aes(x=edge_th,y=communities,color=degree_max,group=degree_max))
# g+geom_line()+xlab(expression(theta[w]))+stdtheme
# ggsave(file=paste0(figdir,'com-eth.png'),width=15,height=10,units='cm')
# 
# g = ggplot(d[d$freqmin==0,],aes(x=edge_th,y=modularity,color=degree_max,group=degree_max))
# g+geom_line()+xlab(expression(theta[w]))+stdtheme
# ggsave(file=paste0(figdir,'mod-eth.png'),width=15,height=10,units='cm')
# 
# 
# g = ggplot(d[d$freqmin==0,],aes(x=edge_th,y=vertices,color=degree_max,group=degree_max))
# g+geom_line()+xlab(expression(theta[w]))+stdtheme
# ggsave(file=paste0(figdir,'vertices-eth.png'),width=15,height=10,units='cm')
# 
# 
# # try pareto modularity/vertices
# g = ggplot(d[d$freqmin==0,],aes(x=vertices,y=communities,color=edge_th))
# g+geom_point()+scale_colour_continuous(name=expression(theta[w]))+stdtheme
# ggsave(file=paste0(figdir,'pareto-com-vertices.png'),width=15,height=10,units='cm')
# 
# g = ggplot(d[d$freqmin==0,],aes(x=vertices,y=modularity,color=edge_th))
# g+geom_point()+scale_colour_continuous(name=expression(theta[w]))+stdtheme
# ggsave(file=paste0(figdir,'pareto-modularity-vertices.png'),width=15,height=10,units='cm')
# 
# 
# # freqmin == 0 always better
# #d[d$freqmin==0&d$modularity>0.5&d$vertices>6000,]
# d[d$freqmin==0&d$modularity>0.75&d$vertices>35000,]

#kminopt=0;kmaxopt=500;freqminopt=0;freqmaxopt=10000;ethopt=10
kminopt=0;kmaxopt=500;freqminopt=0;freqmaxopt=10000;ethopt=5

set.seed(0)
sub<-extractSubGraphCommunities(semantic,kminopt,kmaxopt,freqminopt,freqmaxopt,ethopt)
coms=sub$com

# no need to save

probas = computeThemProbas(sub$gg,sub$com,res$keyword_dico)
save(probas,sub,coms,file=paste0('processed/',mongobase,'_probas_',kwLimit,'_eth',eth_graph,'_nonfiltdico_kmin',kminopt,'_kmax',kmaxopt,'_freqmin',freqminopt,'_freqmax',freqmaxopt,'_eth',ethopt,'.RData'))


