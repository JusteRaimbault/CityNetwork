#################
## Systematic Review Algo study
#################


setwd(paste0(Sys.getenv('CN_HOME'),"/Models/Biblio/AlgoSR"))

#################
## Utils functions

# returns data frame of results
executeAlgo <- function(query,resDir,numIteration,kwLimit){
  #java command to execute algo from jar
  # providing query and result directory
  conf <- read.table('confRScript.conf',sep=";",header=TRUE)
  command <- paste0('java -jar ',conf$jar,' ',query,' ',resDir,' ',numIteration,' ',kwLimit,' ',conf$conf)
  show(paste('Executing ',command))
  system(command)
  res = read.table(paste0(resDir,"/stats.csv"),header=FALSE,sep=";")
  return(res)
}





################
# initial query
#query <- 'transportation+network+city+growth'
#resDir <- paste0('Results/Biblio/AlgoSR/runs/run_1_',query)
#defNumIt = '2'
#defKwLimit = '10'


# test algo function
#executeAlgo(query,resDir,defNumIt,defKwLimit)


################
# Exploration of algo behavior

#########
# Systematic explo in grid (some kws,limits)
#    Q : what max limit ? try to find convergence step as a function of kw num ?
#

# CV for ≠ kw limit
#queries <- c('transportation+network+urban+growth',
#              'city+system+network',
#              'land+use+transport+interaction',
#              'land+use+transport+interaction+network',
#              'population+density+transport',
#              'urban+structure+traffic',
#              'urban+flow+development',
#              'urban+morphogenesis+network',
#              'network+urban+modeling',
#              'transfer+theorem+probability',
#              'bike+sharing+transportation+system',
#              'bike+sharing',
#              'urban',
#              'city'
#              )
#resDir <- 'junk'

queries<-c("land+use+transport+interaction","city+system+network","network+urban+modeling","population+density+transport","transportation+network+urban+growth","urban+morphogenesis+network")
resDir <- 'cit'
#limits<-c(1,2,3,4,5,6,7,8,9,10,15,20,25,30)
limits<-c(30)
maxIt <- 20

res=pairlist()
for(query in queries){

  nrefs = matrix(data=rep(0,maxIt*length(limits)),nrow=maxIt)
  resIt = pairlist();
  for(l in 1:length(limits)){
     resIt[[l]] = executeAlgo(query,resDir,maxIt,limits[l])
  }
  res[[query]]=resIt
}

save(res,file = 'res.rdata');



#################
## Result vizualisation
#
# 
load("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/res.rdata")
# 
library(ggplot2)
library(grid)
vplayout <- function(x, y) viewport(layout.pos.row = x, layout.pos.col = y)

time = 1:maxIt
#kwIndex = 1

grid.newpage()
pushViewport(viewport(layout = grid.layout(3, 4)))

kwIndexes = c(1:7,9,11:13)

for(kwIndex in 1:length(kwIndexes)){
show(queries[kwIndexes[kwIndex]])
kwLimit = c();refs=c()
for(i in 1:length(res[[kwIndexes[kwIndex]]])){
  for(t in 1:maxIt){
    refs = append(refs,res[[kwIndexes[kwIndex]]][[i]][t,1]);
    kwLimit = append(kwLimit,limits[i])
  }
}

#show(floor(kwIndex/4)+1);show((kwIndex%%4))
dat = data.frame(refs,kwLimit,time)
print(ggplot(dat, aes(colour=kwLimit, y= refs, x= time))
      + geom_line(aes(group=kwLimit))
      + ggtitle(queries[kwIndexes[kwIndex]]),
       vp = vplayout(floor((kwIndex-1)/4)+1,kwIndex-(floor((kwIndex-1)/4))*4))
}




################
## Measure of "coherence" of final reference set ?
##   --> sort of semantic distance between all references ? Ok but hard to compute.
##     Skewness of distrib should do the trick ?

# tests

bars <- function(qIndex,lIndex){
  # need to normalize !
  m = as.matrix(res[[queries[qIndex]]][[lIndex]][,(limits[lIndex]+2):(2*limits[lIndex]+1)],)
  for(i in 1:length(m[,1])){
    m[i,] <- m[i,] / res[[queries[qIndex]]][[lIndex]][i,1]
  }
  
  colnames(m) <- (1:length(m[1,]))
  show(colnames(m))
  barplot(
    m
    ,beside=TRUE
    ,main=queries[qIndex]
    #,names.arg=
    )
}

par(mfrow=c(2,2))
bars(5,2);bars(6,2);bars(7,2);bars(8,2)
par(mfrow=c(2,2))
bars(1,2);bars(2,2);bars(3,2);bars(4,2)


################
## Lexical proximity
#  -> cooccurrences can give a relatively good proxy
#  by taking mean(d(i,j)) where d(i,j)=abs(coocc(i)-coocc(j))
#   with normalized coocc.
#  totally equal cooccs give zeros, best coherence possible.
#
#   ADD Coccs fields in java app.

n = length(res[[queries[1]]][[1]][,1])
p = length(res[[queries[1]]][[1]][1,])



lexicalConsistence <- function(qIndex,lIndex){
  n = length(res[[queries[qIndex]]][[lIndex]][,1])
  p = length(res[[queries[qIndex]]][[lIndex]][1,])
  m = as.matrix(res[[queries[qIndex]]][[lIndex]][n,(2*limits[lIndex]+2):p])
  m <- m / res[[queries[qIndex]]][[lIndex]][n,1]
  
  # compute indicator
  N = length(m)
  s=0
  for(i in 1:(N-1)){for(j in (i+1):N){
    s = s + abs(m[i]-m[j])
  }}
  
  return(2/(N*(N-1))*s)
  
}

#lexicalConsistence(1,1)

#kwIndexes = c(1:7,9,11:13)
kwIndexes = c(1,3,5,7,9)

query=c();cons=c();lims=c()
for(kwIndex in 1:length(kwIndexes)){
  show(kwIndexes[kwIndex])
  
  for(l in 1:length(limits)){
    query=append(kwIndex,query);
    cons=append(lexicalConsistence(kwIndexes[kwIndex],l),cons);
    lims = append(limits[l],lims);
  }
}

d = data.frame(query,cons,lims)
ggplot(d, aes(colour=query, y= cons, x= lims))+ geom_line(aes(group=query))



## same with mean and std
kwIndexes = c(1:7,9,11:13)

meanCons=c();sdCons=c();lims=c()
for(l in 1:length(limits)){
  localCons = c()
  for(kwIndex in 1:length(kwIndexes)){localCons=append(lexicalConsistence(kwIndexes[kwIndex],l),localCons)}
  meanCons=append(mean(localCons),meanCons);
  sdCons = append(sd(localCons),sdCons);
  lims = append(limits[l],lims);
}

d = data.frame(meanCons,sdCons,lims)
ggplot(d, aes( y= meanCons, x= lims))+
   geom_line() +
   geom_point() +
   geom_errorbar(aes(ymin=meanCons-sdCons, ymax=meanCons+sdCons), width=.2) + 
   ggtitle("Lexical consistence = f(keyword limit)") +
   xlab("keyword limit") + ylab("mean consistence")








