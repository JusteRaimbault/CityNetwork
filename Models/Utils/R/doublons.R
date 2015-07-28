
library(hash)


##
#  Get a reduced data frame from initial data,
#   where rows with identical values of similar_columns have been merged into 
#   single rows, with new column number
#   length(unique(data[,year_column)) (==number of years) x ncol(data)
#
getUniqueData <-function(data,similar_columns,year_column,wanted_columns){
  # to be in linear time, must fill the final result directly
  res=list()
  keys=hash() # hash list used to store indices of already existing elements
  years=sort(unique(data[,year_column])) # sorted list of years
  for(i in 1:nrow(data)){
    if(i%%10000==0){show(i)}
    simval = data[i,similar_columns]
    key = Reduce(paste0,as.character(simval),"") #unique character key
    year_index = which(years==data[i,year_column]) # current year
    if(is.null(keys[[key]])){
      # construct a new row
      new_row = rep(NA,length(wanted_columns)*length(years))
      new_row[(((year_index-1)*length(wanted_columns)+1):(year_index*length(wanted_columns)))] = data[i,] # fill the corresponding year
      res = append(res,new_row)
      keys[[key]] = length(keys) + 1
    }else{
      ind = keys[[key]]
      res[((((year_index-1)*length(wanted_columns)+1):(year_index*length(wanted_columns))) + (ind - 1)*length(wanted_columns)*length(years))] = data[i,]
    }
  }
  
  # construct the final data frame
  res_df = data.frame(matrix(data=res,nrow=length(keys),byrow=TRUE))
  #show(res_df)
  # construct new colnames
  names=c()
  for(y in years){names=append(names,sapply(colnames(data),function(s){paste0(s,"_",y)}))}
  colnames(res_df)=names
  return(res_df)
}






# test
d=data.frame(x=c(1,1,2,2),y=c(2,2,4,4),z=c(7,9,11,15),year=c(2000,2002,2000,2002))
getUniqueData(d,c(1,2),4,1:4)

#OK

# test large data
size=100000
d=data.frame(x=sample.int(500,size=size,replace=TRUE),y=sample.int(200,size=size,replace=TRUE),z=rnorm(size),year=2000+sample.int(10,size=size,replace=TRUE))
startTime = proc.time()[3]
u=getUniqueData(d,c(1,2),4,1:4)
show(startTime = proc.time()[3]-startTime)
nrow(u)



