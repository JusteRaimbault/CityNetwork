



##
#  Get a reduced data frame from initial data,
#   where rows with identical values of similar_columns have been merged into 
#   single rows, with new column number
#   length(unique(data[,year_column)) (==number of years) x ncol(data)
#
getUniqueData <-function(data,similar_columns,year_column){
  # to be in linear time, must fill the final result directly
  res=list()
  keys=list() # hash list used to store indices of already existing elements
  years=sort(unique(data[,year_column])) # sorted list of years
  for(i in 1:length(data)){
    simval = data[i,similar_columns]
    key = Reduce(paste0,as.character(simval),"") #unique character key
    year_index = which(years==data[i,year_column]) # current year
    if(is.null(keys[[key]])){
      # construct a new row
      new_row = rep(NA,ncol(data)*length(years))
      new_row[(((year_index-1)*ncol(data)+1):(year_index*ncol(data)))] = data[i,] # fill the corresponding year
      res = append(res,list(new_row))
      keys[[key]] = length(res) # necessarily last element of the list
    }else{
      ind = keys[[key]]
      current_row = unlist(res[[ind]])
      current_row[(((year_index-1)*ncol(data)+1):(year_index*ncol(data)))] = data[i,]
      res[[ind]]=list(current_row)
    }
  }
  
  # construct the final data frame
  res_df = data.frame(matrix(unlist(res),nrow=length(res),byrow=TRUE))
  # construct new colnames
  names=c()
  for(y in years){names=append(names,sapply(colnames(data),function(s){paste0(s,"_",y)}))}
  colnames(res_df)=names
  return(res_df)
}






# test
d=data.frame(x=c(1,1,2,2),y=c(2,2,4,4),z=c(9,9,9,9),year=c(2000,2002,2000,2002))
getUniqueData(d,c(1,2),4)

#OK





