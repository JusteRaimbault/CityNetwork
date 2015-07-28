
# convert population grids obtained from calibration
# to a specific format

# get best params rows, param_values and indic_values from morpho_calib script
# best_params_rows = ...
# best_params = ...

# given a param and indics means, must find representative closest to this centroid

representatives = matrix(0,nrow(best_params),ncol(res))
r=1

for(p in 1:nrow(params)){
  if(best_params_rows[p]){
    show(p)
    values = res[as.logical(apply(res[,params_cols]==kronecker(rep(1,nrow(res)),as.matrix(m[p,6:10])),1,prod)),]
    d=apply((values[,indics_cols[c(1,2,3,5)]]-kronecker(rep(1,nrow(values)),as.matrix(m[p,indics_cols_m[c(1,2,3,5)]]))),1,function(x){sum(x^2)})
    show(as.matrix(values[d==min(d)[1],]))
    representatives[r,]=as.matrix(values[d==min(d)[1],])
    r=r+1
  }
}

colnames(representatives)<-colnames(res)


files<-list.files("pop")

# check one
fileName<-function(params){
  #return(paste0("pop/temp_pop_",params["population"],"_",params["diffusion"],"_",params["diffusionsteps"],
  #              "_",params["growthrate"],"_",params["alphalocalization"],"_",params["replication"],".csv"
  #              ))
  # use integer keys : rep and diffSteps
  inds=sapply(files,function(s){grepl(paste0(params["replication"],".csv"),s)})&sapply(files,function(s){grepl(paste0("_",params["diffusionsteps"],"_"),s)})
  return(files[inds])
}

# test if the file exists
z=read.csv(paste0("pop/",fileName(representatives[200,c(params_cols,9)])),sep=";",header=FALSE)
# -> DOES NOT WORK, ROUNDING ISSUES
persp(x=1:50,y=1:50,z=as.matrix(z))



# now get configs and convert

for(r in 1:nrow(representatives)){
  
  
}



