
#################
## Exploration Utilities
#################


## Compute points of a grid, 
# given min, max and step for each param, as a list of arrays.
gridExperiencePlan<-function(parameters){
  vals = seq(from=parameters[[1]][1],to=parameters[[1]][2],by=parameters[[1]][3])
  currentPlan = matrix(vals,nrow=length(vals))
  for(k in 2:length(parameters)){
    vals = seq(from=parameters[[k]][1],to=parameters[[k]][2],by=parameters[[k]][3])
    currentPlan = extendPlan(vals,currentPlan)
  }
  return(currentPlan)
}

# aux function
extendPlan<-function(newVals,previousPlans){
  res = matrix(0,nrow(previousPlans)*length(newVals),ncol(previousPlans)+1)
  r=1
  for(k in 1:nrow(previousPlans)){
    for(v in 1:length(newVals)){
      res[r,1:(ncol(res)-1)]=previousPlans[k,];res[r,ncol(res)]=newVals[v]
      r=r+1
    }
  }
  return(res)
}



## explore a stochastic function following a plan, with given number of repets
# returns matrix with function values and param values.
explore<-function(f,nrep,plan,paramIndexes=ncol(plan),fixedArgs=list(),fixedArgsIndexes=c()){
  # TODO : fixed args
  
  # get output dimension : empty run
  d = length(do.call(f,as.list(plan[1,])))
  
  res = matrix(0,nrep*nrow(plan),d + ncol(plan))
  
  r=1
  for(p in 1:nrow(plan)){
    for(n in 1:nrep){
      res[r,1:ncol(plan)]=plan[p,]
      res[r,(ncol(plan)+1):ncol(res)] = do.call(f,as.list(plan[p,]))
      r=r+1
    }
  }
  return(res)
  
}


testfun<-function(x1,x2,x3){
  return(x1+x2+x3)
}







