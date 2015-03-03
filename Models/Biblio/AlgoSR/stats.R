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
             'population+density+transport',
             'urban+structure+traffic',
             'urban+flow+development',
             'urban+morphogenesis+network',
             'network+urban+modeling'
             )
resDir <- 'junk'
limits<-c(2,5,7,10,15,20,25,30)
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










