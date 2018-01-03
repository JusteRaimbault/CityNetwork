
#
namesTS <-function(names,finalTime){
  res=c()
  for(name in names){
    if(length(grep('TS',name,fixed=T))>0){res=append(res,paste0(name,1:finalTime))}
    else{res=append(res,name)}
  }
  return(res)
}
