#################
## Systematic Review Algo study
#################

#################
## Utils functions

# returns data frame of results
executeAlgo <- function(query,resDir,numIteration,kwLimit){
  #java command to execute algo from jar
  # providing query and result directory
  command <- paste0('java -jar /Users/Juste/Documents/ComplexSystems/CityNetwork/Models/Biblio/AlgoSR/algosr.jar ',query,' ',resDir,' ',numIteration,' ',kwLimit)
  show(paste('Executing ',command))
  system(command)
  res = read.table(paste0(resDir,"/stats.csv"),header=FALSE,sep=";")
  return(res)
}





################
# initial query
query <- 'transportation+network+city+growth'
resDir <- paste0('Results/Biblio/AlgoSR/runs/run_1_',query)
defNumIt = '2'
defKwLimit = '10'


# test algo function
executeAlgo(query,resDir,defNumIt,defKwLimit)


################
# Exploration of algo behavior

# CV for ≠ kw limit
query <- 'transportation+network+urban+growth'
resDir <- 'Results/Biblio/AlgoSR/junk'
limits<-c(2,5,10,15,20)
maxIt <- 5


nrefs = matrix(data=rep(0,maxIt*length(limits)),nrow=maxIt)
for(l in 1:length(limits)){
  res = executeAlgo(query,resDir,maxIt,limits[l])
  for(k in 1:length(res[,1])){nrefs[k,l]=res[k,1]}
  for(k in length(res[,1]):20){nrefs[k,l]=nrefs[length(res[,1]),l]}
}


#########
# Systematic explo in grid (some kws,limits)
#    Q : what max limit ?
#







