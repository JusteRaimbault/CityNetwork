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
queries <- c('transportation+network+urban+growth')
resDir <- 'junk'
limits<-c(2)#,5,10,15,20)
maxIt <- 20


for(query in queries){

  nrefs = matrix(data=rep(0,maxIt*length(limits)),nrow=maxIt)
  for(l in 1:length(limits)){
     res = executeAlgo(query,resDir,maxIt,limits[l])
     for(k in 1:maxIt){nrefs[k,l]=res[k,1]}
     #for(k in length(res[,1]):maxIt){nrefs[k,l]=nrefs[length(res[,1]),l]}
  }
  show(nrefs)
}









