

getLinearModels<-function(yvar,vars,nvars){
  # brute force with enumerating all sets
  varsets =list(c())
  for(i in 1:nvars){
    newsets = list();j=1
    for(prevset in varsets){
      for(var in vars){
        newsets[[j]]=union(prevset,c(var));j=j+1
      }
    }
    k=1;varsets=list()
    for(j1 in 1:length(newsets)){
      toadd=TRUE
      if(length(varsets)>0){
        for(j2 in 1:length(varsets)){
          toadd=toadd&(!setequal(newsets[[j1]],varsets[[j2]]))
        }
      }
      if(toadd){varsets[[k]]=newsets[[j1]];k=k+1}
    }
    #show(varsets)
  }
  res=c()
  for(varset in varsets){
    if(length(varset)<=nvars){
      currentmodel=paste0(yvar,"~",varset[1])
      if(length(varset)>1){for(var in varset[2:length(varset)]){currentmodel=paste0(currentmodel,"+",var)}}
      res=append(res,currentmodel)
    }
  }
  return(res)
}

