
# corpus construction for modelography
#  (following interdisc)

library(igraph)
library(dplyr)
library(randomForest)
library(MuMIn)
library(ggplot2)
library(stargazer)

source(paste0(Sys.getenv('CN_HOME'),'/Models/Utils/R/plots.R'))

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/QuantEpistemo/HyperNetwork/Modelography'))

source('functions.R')

load(paste0(Sys.getenv('CN_HOME'),'/Models/QuantEpistemo/HyperNetwork/HyperNetwork/processed/citation.RData'))

resdir = paste0(Sys.getenv('CN_HOME'),'/Results/QuantEpistemo/Modelography/')


#######
## KW corpus

# cit nw is subcit

# rq : sem compo of cit coms are rather balanced
#  -> use directly semantic communities, select kws on degree, a given proportion of each class

kws = data.frame()
for(k in unique(coms$membership)){
  show(paste0('Com ',k,', size : ',length(which(coms$membership==k)),' , weight docs : ',100*colSums(probas)[k]/sum(probas)))
  vertices=(coms$membership==k)
  currentnames=V(gg)$name[vertices];currentdegree=degree(gg)[vertices]
  #degth = sort(currentdegree,decreasing = T)[20]
  degth = quantile(currentdegree,0.8)
  kws = rbind(kws,data.frame(name=currentnames[currentdegree>=degth],degree=currentdegree[currentdegree>=degth]))
}


# by weight ?
kwedges = E(gg)[E(gg)$weight>quantile(E(gg)$weight,0.95)&head_of(gg,E(gg))$name%in%as.character(kws$name)&tail_of(gg,E(gg))$name%in%as.character(kws$name)]

write.csv(c(unique(c(head_of(gg,kwedges)$name,tail_of(gg,kwedges)$name)),paste0(head_of(gg,kwedges)$name,' ',tail_of(gg,kwedges)$name)),file='modelography/kwsraw.csv')


#########
## citation core
write.table(data.frame(V(citationcore)$title,V(citationcore)$name,V(citationcore)$year,V(citationcore)$citmemb),row.names = F,col.names = F,file='modelography/citationcore.csv',sep=',')




########
## consolidate

corpus = read.csv(file='modelography/corpus_manual.csv',header=F,sep=';',colClasses = c('character','character','character'))
citcore = read.csv(file='modelography/citationcore_manual.csv',header=F,sep=',',colClasses = c('character','character','character','character'))

full = rbind(cbind(corpus,V4=rep(NA,nrow(corpus))),citcore)

full = full[!duplicated(full$V2),]

write.table(full,row.names = F,col.names = F,sep=";",file='modelography/full.csv')


#######
## interdisc, sem domains

full=as.tbl(read.csv(file='modelography/full_manual.csv',header=T,sep=';',colClasses = rep('character',16)))

#abstract = as.tbl(read.csv('modelography/full_abstract.csv.csv',header=F,sep=';',colClasses = rep('character',5)))
# c('15548407300627151288','11803165925574305142','17412736314612590072')
# fucking bug with RMongo, bad type retrievment. depending on result size, parses or not, and parses into integers with imprecision..
# do it dirty
reducedids = full$ID;names(reducedids)<-substr(full$ID,1,10)
names(keyword_dico)<-sapply(names(keyword_dico),function(s){reducedids[substring(s,1,10)]})

# citations
full$CITCOM = unlist(sapply(full$CITCOM,function(s){ifelse(is.na(s)|!s%in%names(citcomnames),NA,citcomnames[s])}))
# semantic
# -> source sensitivity, interdisc
full$INTERDISC = interdisc[full$ID,'interdisc']
full$SEMCOM = sapply(full$ID,function(s){ifelse(!s%in%rownames(probas),NA,ifelse(sum(probas[s,])==0,NA,semnames[which(probas[s,]==max(probas[s,]))]))})
full$YEAR=as.numeric(full$YEAR)
full$TEMPSCALE=as.numeric(full$TEMPSCALE)

write.table(full,row.names = F,col.names = T,sep=";",file='modelography/full_consolidated.csv',na = 'NA')

#####
## first stats

#"TITLE";"ID";"YEAR";"CITCOM";"MODEL";"TYPE";"TEMPSCALE";"SPATSCALE";"METHODO";
#"EQU";"THEME";"CASE";"DISCIPLINE";"PROCESSES";"OBSERVATION";"LINK";"INTERDISC";"SEMCOM"
full=as.tbl(read.csv(file='modelography/full_consolidated.csv',header=T,sep=';',
    colClasses = c('character','character','integer','factor','factor','factor','numeric','factor','character',
                   'factor','character','character','factor','character','character','character','numeric','factor')))

# main method
full$FMETHOD = sapply(strsplit(full$METHODO,split=','),function(s){s[1]})
full$SPATSCALE = sapply(as.character(full$SPATSCALE),function(s){ifelse(nchar(s)==0,NA,ifelse(s=="metro",10,ifelse(s=="region",100,ifelse(s=='country',1000,ifelse(s=='continent',10000,1)))))})
full$EQU<-as.character(full$EQU);full$EQU[nchar(full$EQU)==0]=NA;full$EQU<-as.factor(full$EQU)
as.character(full$TYPE)

table(full$DISCIPLINE,full$MODEL)

# clean data
data = full[as.character(full$MODEL)=='yes',c("YEAR","CITCOM","TYPE","TEMPSCALE","SPATSCALE","FMETHOD","DISCIPLINE","INTERDISC","SEMCOM")]
data$TYPE=as.factor(as.character(data$TYPE))
# all observations
datafull=data[!is.na(data$YEAR)&!is.na(data$CITCOM)&!is.na(data$TYPE)&!is.na(data$TEMPSCALE)&!is.na(data$SPATSCALE)&!is.na(data$FMETHOD)&!is.na(data$DISCIPLINE)&!is.na(data$INTERDISC)&!is.na(data$SEMCOM),]
# -> very few full rows

###

## processes and case studies

table(full$CASE[as.character(full$MODEL)=='yes'])/length(which(as.character(full$MODEL)=='yes'))*100

# by discipline
table(full$CASE[as.character(full$MODEL)=='yes'],full$DISCIPLINE[as.character(full$MODEL)=='yes'])

table(full$PROCESSES[as.character(full$MODEL)=='yes'])/length(which(as.character(full$MODEL)=='yes'))*100



## summary stats

# disciplines
table(data$DISCIPLINE)/nrow(data)*100
# semantic
table(data$SEMCOM)/nrow(data)*100
# compo sem par discipline
table(data$DISCIPLINE,data$SEMCOM)
# interdisc par discipline
data%>%group_by(DISCIPLINE)%>%summarise(INTERDISC=mean(INTERDISC,na.rm=T))

# who does what
table(data$TYPE,data$DISCIPLINE)
table(data$TYPE,data$SEMCOM)
table(data$TYPE,data$CITCOM)

table(data$SPATSCALE,data$CITCOM)
table(data$SPATSCALE,data$DISCIPLINE)
table(data$SPATSCALE,data$SEMCOM)

table(data$TEMPSCALE,data$CITCOM)
table(data$TEMPSCALE,data$DISCIPLINE)
table(data$TEMPSCALE,data$SEMCOM)

# how ? -> scales, regressions.

#table(data$TEMPSCALE,data$CITCOM)
#table(data$FMETHOD,data$DISCIPLINE)


# chisquare tests

chisq.test(data$FMETHOD,data$DISCIPLINE,simulate.p.value = T,B=100000)

chisq.test(data$SPATSCALE,data$DISCIPLINE,simulate.p.value = T,B=100000)

cor.test(data$SPATSCALE,data$TEMPSCALE) # strange. too few observations.

# Linear models

# tempscale

#tscalefull = lm(TEMPSCALE~YEAR+CITCOM+TYPE+SPATSCALE+DISCIPLINE+INTERDISC+SEMCOM+FMETHOD,data=data)
#tscaleclass = lm(TEMPSCALE~CITCOM+DISCIPLINE+SEMCOM,data=data)
#AIC(tscaleclass)-AIC(tscalefull)
#summary(tscalefull)
#summary(tscaleclass)

evaluateModels<-function(models){
  aics=c();aiccs=c();numrows=c();numvars=c();adj.r.squared=c();rsquared=c()
  for(model in models){
    show(model);
    solved = lm(model,data)
    aics=append(aics,AIC(solved))
    aiccs=append(aiccs,AICc(solved))
    numrows=append(numrows,length(solved$residuals))
    numvars=append(numvars,length(solved$coefficients)-1)
    adj.r.squared=append(adj.r.squared,summary(solved)$adj.r.squared)
    rsquared=append(rsquared,summary(solved)$r.squared)
  }
  return(data.frame(aics,aiccs,numrows,numvars,adj.r.squared,rsquared))
}

var = "TEMPSCALE"

models <- getLinearModels(var,names(data)[-4],8)
comp <- evaluateModels(models)

minrows = 50

summary(lm(models[modelcomparison$aics[modelcomparison$numrows>80]==min(modelcomparison$aics[modelcomparison$numrows>80])],data)) # -> tscalefull is the best.
summary(lm(models[comp$aiccs==min(comp$aiccs)],data)) 
summary(lm(models[aics==min(aics)],data)) 
model=models[which(comp$adj.r.squared==max(comp$adj.r.squared[comp$numrows>minrows]))]
summary(lm(model,data))

#g=ggplot(data.frame(numrows,numvars,aics),aes(x=numrows,y=aics,color=numvars))
#g+geom_point()+stdtheme#+scale_color_continuous(guide='legend')

#g=ggplot(comp,aes(x=adj.r.squared,y=aiccs,color=as.character(numrows)))
#g+geom_point()

#g=ggplot(comp[comp$numrows>minrows,],aes(x=aiccs,y=rsquared,color=as.character(numrows)))
#g+geom_point()+stdtheme

g=ggplot(comp[comp$numrows>minrows,],aes(x=aiccs,y=adj.r.squared,color=as.character(numrows)))
g+geom_point()+stdtheme+xlab("AICc")+scale_color_discrete(name="N")+ylab("Adjusted R Squared")+ggtitle(var)
ggsave(paste0(resdir,"lm_adjr2-aicc_",var,".pdf"),width=17,height=15,units = 'cm')

#
model=models[comp$adj.r.squared==max(comp$adj.r.squared[comp$numrows>minrows&comp$aiccs<700])]
summary(lm(model,data))
#stargazer(lm(model,data))
tempscale = lm(model,data)

model2=models[comp$adj.r.squared==max(comp$adj.r.squared[comp$numrows>minrows&comp$aiccs>700])]
tempscale2 = lm(model2,data)

# spat scale

var="SPATSCALE"
models <- getLinearModels(var,names(data)[-5],8)
comp <- evaluateModels(models)
#summary(lm(models[comp$aiccs==min(comp$aiccs)],data))
#summary(lm(models[comp$aiccs[comp$numrows>minrows]==min(comp$aiccs[comp$numrows>minrows])],data))
g=ggplot(comp[comp$numrows>minrows,],aes(x=aiccs,y=adj.r.squared,color=as.character(numrows)))
g+geom_point()+stdtheme+xlab("AICc")+scale_color_discrete(name="N")+ylab("Adjusted R Squared")+ggtitle(var)
ggsave(paste0(resdir,"lm_adjr2-aicc_",var,".pdf"),width=17,height=15,units = 'cm')

model=models[comp$adj.r.squared==max(comp$adj.r.squared[comp$numrows>minrows&comp$aiccs<2000&comp$aiccs>1500])]
spatscale = lm(model,data)
summary(spatscale)

# interdisc
var="INTERDISC"
models <- getLinearModels(var,names(data)[-8],8)
comp <- evaluateModels(models)
g=ggplot(comp[comp$numrows>minrows,],aes(x=aiccs,y=adj.r.squared,color=as.character(numrows)))
g+geom_point()+stdtheme+xlab("AICc")+scale_color_discrete(name="N")+ylab("Adjusted R Squared")+ggtitle(var)
ggsave(paste0(resdir,"lm_adjr2-aicc_",var,".pdf"),width=17,height=15,units = 'cm')

model=models[comp$adj.r.squared==max(comp$adj.r.squared[comp$numrows>minrows&comp$aiccs>-100])]
interdisc = lm(model,data)

model2=models[comp$adj.r.squared==max(comp$adj.r.squared[comp$numrows>minrows&abs(comp$aiccs)>100])]
interdisc2 = lm(model2,data)

# year
var="YEAR"
models <- getLinearModels(var,names(data)[-1],8)
comp <- evaluateModels(models)
g=ggplot(comp[comp$numrows>minrows,],aes(x=aiccs,y=adj.r.squared,color=as.character(numrows)))
g+geom_point()+stdtheme+xlab("AICc")+scale_color_discrete(name="N")+ylab("Adjusted R Squared")+ggtitle(var)
ggsave(paste0(resdir,"lm_adjr2-aicc_",var,".pdf"),width=17,height=15,units = 'cm')

model=models[comp$adj.r.squared==max(comp$adj.r.squared[comp$numrows>minrows&comp$aiccs<600])]
year = lm(model,data)

#model2=models[comp$adj.r.squared==max(comp$adj.r.squared[comp$numrows>minrows&comp$aiccs>700&comp$aiccs<800])]
#year2 = lm(model2,data)

###
stargazer(tempscale,tempscale2,spatscale,interdisc,interdisc2,year,no.space = T,#se = list(rep(NA,length(tempscale$coefficients)),rep(NA,length(tempscale2$coefficients)),rep(NA,length(spatscale$coefficients)),rep(NA,length(interdisc$coefficients)),rep(NA,length(interdisc2$coefficients)),rep(NA,length(year$coefficients))),
          out = paste0(resdir,'lmregs_nosd.tex'),single.row = T,report="vc*")

# individual variable reporting
stargazer(tempscale,tempscale2,no.space = T,
          out = paste0(resdir,'lmtempscale.tex'),single.row = T,ci=TRUE,report="vcsp*")

stargazer(spatscale,no.space = T,
          out = paste0(resdir,'lmspatscale.tex'),single.row = T,ci=TRUE,report="vcsp*")

stargazer(interdisc,interdisc2,no.space = T,
          out = paste0(resdir,'lminterdisc.tex'),single.row = T,ci=TRUE,report="vcsp*")

stargazer(year,no.space = T,
          out = paste0(resdir,'lmyear.tex'),single.row = T,ci=TRUE,report="vcsp*")






########


# Random forest

# type of model
rf<-randomForest(TYPE~SEMCOM+CITCOM+DISCIPLINE,
                 data=data[!is.na(data$TYPE)&!is.na(data$SEMCOM)&!is.na(data$CITCOM)&!is.na(data$DISCIPLINE),],
                 nodesize=1,ntree=100000
)
rf$importance/sum(rf$importance)


rf<-randomForest(INTERDISC~SEMCOM+CITCOM+DISCIPLINE,
                 data=full[!is.na(full$INTERDISC)&!is.na(full$SEMCOM)&!is.na(full$CITCOM)&!is.na(full$DISCIPLINE),],
                 nodesize=1,ntree=100000
                 )
rf$importance/sum(rf$importance)





