

data = data.frame(carro=sample.int(10,400,replace=TRUE),matrix(rnorm(400),nrow=100))
carro_id_column = 1

# general function
#  data : all data
#  carro_id_column : column of carro_id
#  target_column : columns on which computation is done
#  fun_to_apply : customizable function : matrix -> array
applyByCarro<-function(data,carro_id_column,target_columns,fun_to_apply){
  res = list()
  u = unique(data[,carro_id_column])
  for(id in u){
    res = append(res,list(fun_to_apply(data[data[,carro_id_column]==id,target_columns])))
  }
  return(matrix(unlist(res),nrow=length(u),byrow=TRUE))
}


# example 1 : compute (mean,variation_rate) of one column
example_1 <- function(d){c(mean(d),d[length(d)]-d[1])}
applyByCarro(data,carro_id_column,c(2),example_1)

# example 2 : compute (mean(column1),...,mean(columnK))
example_2 <- colMeans
applyByCarro(data,carro_id_column,2:4,example_2)


