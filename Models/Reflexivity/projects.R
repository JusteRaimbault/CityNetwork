
library(dplyr)
library(ggplot2)
library(reshape2)
library(igraph)

source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/Reflexivity'))

resdir = paste0(Sys.getenv('CN_HOME'),'/Results/Reflexivity/')


time <- as.tbl(read.csv(file='data/time.csv',header = T,sep = ";",dec = ",",na.strings = c("")))
tmat = t(as.matrix(time[,2:ncol(time)]))
colnames(tmat)<-time$Project.Name
dates=rev(as.POSIXct(seq(from=format(as.POSIXct("2015/02/16"),"%s"),to=format(as.POSIXct("2017/12/02"),"%s"),by=86400),origin =strptime(0,format='%s')))
tmat=data.frame(tmat)
tmat$date = dates
tmat[is.na(tmat)]=0
  
d = floor(as.numeric(format(tmat$date,format='%s'))/(7*86400));d=(d-min(d))*7-1;d[d==-1]=1
tmat$week=tmat$date[d]

caracs = as.tbl(read.csv('data/caracs.csv',sep=';'))
mtmat = melt(data=tmat,measure.vars = 1:(ncol(tmat)-2), id.vars = c('date','week'))
sdata = left_join(mtmat,caracs,by=c('variable'='Project'))

#g=ggplot(melt(data=tmat,measure.vars = 1:(ncol(tmat)-1), id.vars = 'date'),aes(x=date,y=value))
#g+geom_area(aes(fill= variable), position = 'stack')+scale_fill_discrete(guide=FALSE)

# group by weeks

g=ggplot(mtmat,aes(x=date,y=value,colour= variable,group=variable))
g+geom_smooth()+scale_colour_discrete(guide=FALSE)

# need to aggregate at a "macro-project" level

weekdata = sdata %>% group_by(week,MacroProject) %>% summarise(time=sum(value))

g=ggplot(weekdata,aes(x=weekdata$week[nrow(weekdata):1],y=time,colour=MacroProject,group=MacroProject))
g+geom_area(aes(fill= MacroProject), position = 'stack')+xlab('Week')+ylab("Time")+stdtheme
ggsave(file=paste0(resdir,'weekly-macroproj.png'),width=25,height=15,units='cm')

g=ggplot(weekdata,aes(x=weekdata$week[nrow(weekdata):1],y=time,colour=MacroProject,group=MacroProject))
g+geom_smooth(span=0.2)

# by chapter

chdata = sdata[sdata$Chapter>0,] %>% group_by(week,Chapter) %>% summarise(time=sum(value))

g=ggplot(chdata,aes(x=chdata$week[nrow(chdata):1],y=time,fill=as.character(Chapter),group=as.character(Chapter)))
g+geom_area( position = 'stack')+xlab('Week')+ylab("Time")+stdtheme+scale_fill_discrete(name='Chapter')
ggsave(file=paste0(resdir,'weekly-chapter.png'),width=25,height=15,units='cm')


# by knowledge domain

kddata = sdata[!is.na(sdata$KnowledgeDomain),] %>% group_by(week,KnowledgeDomain) %>% summarise(time=sum(value))

g=ggplot(kddata,aes(x=kddata$week[nrow(kddata):1],y=time,fill=KnowledgeDomain,group=KnowledgeDomain))
g+geom_area( position = 'stack')+xlab('Week')+ylab("Time")+stdtheme
ggsave(file=paste0(resdir,'weekly-knowledgedomains.png'),width=25,height=15,units='cm')



#######
## Construct flow graphs


probaFlow<-function(data,period,currentdate){
  x = data$time[data$week==period[currentdate]];if(sum(x)>0){x=x/sum(x)}
  #x=as.numeric(x>0)
  return(matrix(rep(x,length(x)),nrow=length(x),byrow = T)*matrix(rep(x,length(x)),nrow=length(x),byrow = F))
}

cooccFlow<-function(data,period,currentdate){
  x = data$time[data$week==period[currentdate]];
  x=as.numeric(x>0)
  return(matrix(rep(x,length(x)),nrow=length(x),byrow = T)*matrix(rep(x,length(x)),nrow=length(x),byrow = F))
}

laggedFlow<-function(data,period,currentdate){
  if(currentdate==1){n=length(which(data$week == period[1]));return(matrix(0,n,n))}
  else{
    x1 = data$time[data$week==period[currentdate]];if(sum(x1)>0){x1=x1/sum(x1)}
    x2 = data$time[data$week==period[currentdate-1]];if(sum(x2)>0){x2=x2/sum(x2)}
    return(matrix(rep(x2,length(x2)),nrow=length(x2),byrow = F)*matrix(rep(x1,length(x1)),nrow=length(x1),byrow = T))
  }
}

laggedCooccs<-function(data,period,currentdate){
  if(currentdate==1){n=length(which(data$week == period[1]));return(matrix(0,n,n))}
  else{
    x1 = data$time[data$week==period[currentdate]];x1=as.numeric(x1>0)
    x2 = data$time[data$week==period[currentdate-1]];x2=as.numeric(x2>0)
    return(matrix(rep(x2,length(x2)),nrow=length(x2),byrow = F)*matrix(rep(x1,length(x1)),nrow=length(x1),byrow = T))
  }
}


#' 
#' @param period : list of dates
cumulatedFlows<-function(data,period,flowfun=probaFlow){
  n=length(which(data$week == period[1]))
  flows = matrix(0,n,n);
  for(currentdate in 1:length(period)){
    flows = flows + flowfun(data,period,currentdate)
  }
  return(flows/length(period))
}


## projects

projectFlows = cumulatedFlows(weekdata,unique(weekdata$week))
rownames(projectFlows)<-unique(weekdata$MacroProject);colnames(projectFlows)<-unique(weekdata$MacroProject);diag(projectFlows)=0
projectGraph = graph_from_adjacency_matrix(projectFlows,mode="undirected",weighted=T)
png(paste0(resdir,'graph-projects-probas.png'),width = 15,height=15,units='cm',res=300)
plot(projectGraph,edge.width=10*E(projectGraph)$weight)
dev.off()

projectFlows = cumulatedFlows(weekdata,unique(weekdata$week),flowfun = cooccFlow)
rownames(projectFlows)<-unique(weekdata$MacroProject);colnames(projectFlows)<-unique(weekdata$MacroProject);diag(projectFlows)=0
projectGraph = graph_from_adjacency_matrix(projectFlows,mode="undirected",weighted=T)
betweenness(projectGraph)
png(paste0(resdir,'graph-projects-cooccs.png'),width = 15,height=15,units='cm',res=300)
plot(projectGraph,edge.width=10*E(projectGraph)$weight)
dev.off()

projectFlows = cumulatedFlows(weekdata,unique(weekdata$week),flowfun = laggedFlow)
rownames(projectFlows)<-unique(weekdata$MacroProject);colnames(projectFlows)<-unique(weekdata$MacroProject);diag(projectFlows)=0
projectGraph = graph_from_adjacency_matrix(projectFlows,mode="directed",weighted=T)
png(paste0(resdir,'graph-projects-laggedflow.png'),width = 15,height=15,units='cm',res=300)
plot(projectGraph,edge.width=150*E(projectGraph)$weight,edge.curved=T,edge.arrow.width=0.2,edge.arrow.size=0.2)
dev.off()

projectFlows = cumulatedFlows(weekdata,unique(weekdata$week),flowfun = laggedCooccs)
rownames(projectFlows)<-unique(weekdata$MacroProject);colnames(projectFlows)<-unique(weekdata$MacroProject);diag(projectFlows)=0
projectGraph = graph_from_adjacency_matrix(projectFlows,mode="directed",weighted=T)
png(paste0(resdir,'graph-projects-laggedcooccs.png'),width = 15,height=15,units='cm',res=300)
plot(projectGraph,edge.width=10*E(projectGraph)$weight,edge.curved=T,edge.arrow.width=0.2,edge.arrow.size=0.2)
dev.off()



##### kd


projectFlows = cumulatedFlows(kddata,unique(kddata$week))
rownames(projectFlows)<-unique(kddata$KnowledgeDomain);colnames(projectFlows)<-unique(kddata$KnowledgeDomain);diag(projectFlows)=0
projectGraph = graph_from_adjacency_matrix(projectFlows,mode="undirected",weighted=T)
png(paste0(resdir,'graph-kd-probas.png'),width = 15,height=15,units='cm',res=300)
plot(projectGraph,edge.width=10*E(projectGraph)$weight)
dev.off()

projectFlows = cumulatedFlows(kddata,unique(kddata$week),flowfun = cooccFlow)
rownames(projectFlows)<-unique(kddata$KnowledgeDomain);colnames(projectFlows)<-unique(kddata$KnowledgeDomain);diag(projectFlows)=0
projectGraph = graph_from_adjacency_matrix(projectFlows,mode="undirected",weighted=T)
png(paste0(resdir,'graph-kd-cooccs.png'),width = 15,height=15,units='cm',res=300)
plot(projectGraph,edge.width=10*E(projectGraph)$weight)
dev.off()


projectFlows = cumulatedFlows(kddata,unique(kddata$week),flowfun = laggedFlow)
rownames(projectFlows)<-unique(kddata$KnowledgeDomain);colnames(projectFlows)<-unique(kddata$KnowledgeDomain);diag(projectFlows)=0
projectGraph = graph_from_adjacency_matrix(projectFlows,mode="directed",weighted=T)
png(paste0(resdir,'graph-kd-laggedflow.png'),width = 15,height=15,units='cm',res=300)
plot(projectGraph,edge.width=100*E(projectGraph)$weight,edge.curved=T,edge.arrow.width=0.2,edge.arrow.size=0.2)
dev.off()

projectFlows = cumulatedFlows(kddata,unique(kddata$week),flowfun = laggedCooccs)
rownames(projectFlows)<-unique(kddata$KnowledgeDomain);colnames(projectFlows)<-unique(kddata$KnowledgeDomain);diag(projectFlows)=0
projectGraph = graph_from_adjacency_matrix(projectFlows,mode="directed",weighted=T)
png(paste0(resdir,'graph-kd-laggedcooccs.png'),width = 15,height=15,units='cm',res=300)
plot(projectGraph,edge.width=10*E(projectGraph)$weight,edge.curved=T,edge.arrow.width=0.2,edge.arrow.size=0.2)
dev.off()




