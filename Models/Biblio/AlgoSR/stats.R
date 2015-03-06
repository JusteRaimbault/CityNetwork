#################
## Systematic Review Algo study
#################

# directory must contain confRScript.conf file
# and called by source(...,chdir=TRUE)

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
queries <- c('transportation+network+urban+growth',
             'city+system+network',
             'land+use+transport+interaction',
             'land+use+transport+interaction+network'
             'population+density+transport',
             'urban+structure+traffic',
             'urban+flow+development',
             'urban+morphogenesis+network',
             'network+urban+modeling',
             'transfer+theorem+probability',
             'bike+sharing+transportation+system',
             'bike+sharing',
             'urban',
             'city'
             )
resDir <- 'junk'
limits<-c(1,2,3,4,5,6,7,8,9,10,15,20,25,30)
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
# load("/Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/res.rdata")
# 
# library(ggplot2)
# library(grid)
# vplayout <- function(x, y) viewport(layout.pos.row = x, layout.pos.col = y)
# 
# time = 1:maxIt
# #kwIndex = 1
# 
# grid.newpage()
# pushViewport(viewport(layout = grid.layout(2, 4)))
# 
# for(kwIndex in 1:length(queries)){
# show(queries[kwIndex])
# kwLimit = c();refs=c()
# for(i in 1:length(res[[kwIndex]])){
#   for(t in 1:maxIt){
#     refs = append(refs,res[[kwIndex]][[i]][t,1]);
#     kwLimit = append(kwLimit,limits[i])
#   }
# }
# 
# #show(floor(kwIndex/4)+1);show((kwIndex%%4))
# dat = data.frame(refs,kwLimit,time)
# print(ggplot(dat, aes(colour=kwLimit, y= refs, x= time))+ geom_line(aes(group=kwLimit)) + ggtitle(queries[kwIndex]), vp = vplayout(floor((kwIndex-1)/4)+1,kwIndex-(floor((kwIndex-1)/4))*4))
# }
# 
# 
# 
# 
# ################
# ## Measure of "coherence" of final reference set ?
# ##   --> sort of semantic distance between all references ? Ok but hard to compute.
# ##     Skewness of distrib should do the trick ?
# 
# # tests
# 
# bars <- function(qIndex,lIndex){
#   # need to normalize !
#   m = as.matrix(res[[queries[qIndex]]][[lIndex]][,(limits[lIndex]+2):(2*limits[lIndex]+1)],)
#   for(i in 1:length(m[,1])){
#     m[i,] <- m[i,] / res[[queries[qIndex]]][[lIndex]][i,1]
#   }
#   
#   colnames(m) <- (1:length(m[1,]))
#   show(colnames(m))
#   barplot(
#     m
#     ,beside=TRUE
#     ,main=queries[qIndex]
#     #,names.arg=
#     )
# }
# 
# par(mfrow=c(2,2))
# bars(5,2);bars(6,2);bars(7,2);bars(8,2)
# par(mfrow=c(2,2))
# bars(1,2);bars(2,2);bars(3,2);bars(4,2)
# 

################
## Lexical proximity
#  -> cooccurrences can give a relatively good proxy
#  by taking mean(d(i,j)) where d(i,j)=abs(coocc(i)-coocc(j))
#   with normalized coocc.
#  totally equal cooccs give zeros, best coherence possible.
#
#   ADD Coccs fields in java app.








