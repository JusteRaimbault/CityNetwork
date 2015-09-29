
# convert population grids obtained from calibration
# to a specific format

# get best params rows, param_values and indic_values from morpho_calib script
# best_params_rows = ...
# best_params = ...

##
# given a param and indics means, must find representative closest to this centroid
# 
#
getRepresentatives<-function(raw_results,aggregated_results,
                             parameter_rows,
                             raw_params_cols,aggregated_params_cols,
                             raw_indics_cols,aggregated_indics_cols
                             ){
 
  repres = matrix(0,length(parameter_rows),ncol(raw_results))
  r=1
  
  for(p in parameter_rows){
      values = raw_results[as.logical(apply(raw_results[,raw_params_cols]==kronecker(rep(1,nrow(raw_results)),as.matrix(aggregated_results[p,aggregated_params_cols])),1,prod)),]
      d=apply((values[,raw_indics_cols]-kronecker(rep(1,nrow(values)),as.matrix(aggregated_results[p,aggregated_indics_cols]))),1,function(x){sum(x^2)})
      #show(as.matrix(values[d==min(d)[1],]))
      repres[r,]=as.matrix(values[d==min(d)[1],])
      r=r+1
  }
  
  colnames(repres)<-colnames(res)
  
  return(repres)
  
}

representatives = getRepresentatives(res,m,best_params_rows,params_cols,6:10,indics_cols[c(1,2,3,5)],indics_cols_m[c(1,2,3,5)])

files<-list.files(paste0(Sys.getenv("CN_HOME"),'/Results/Synthetic/Density/Output/ScalaImpl/20150729_Scala_SamplingLHS/pop'))

# check one
fileName<-function(params){
  #return(paste0("pop/temp_pop_",params["population"],"_",params["diffusion"],"_",params["diffusionsteps"],
  #              "_",params["growthrate"],"_",params["alphalocalization"],"_",params["replication"],".csv"
  #              ))
  # -> DOES NOT WORK, ROUNDING ISSUES
  # use integer keys : rep and diffSteps
  #inds=sapply(files,function(s){grepl(paste0(params["replication"],".csv"),s)})&sapply(files,function(s){grepl(paste0("_",params["diffusionsteps"],"_"),s)})
  #return(files[inds])
  return(paste0(params["replication"],params["diffusionsteps"]))
}

# test if the file exists
z=read.csv(fileName(representatives[1,c(params_cols,9)]),sep=";",header=FALSE)
z=read.csv(paste0("pop/",fileName(res[sample.int(nrow(res),1),c(params_cols,9)])),sep=";",header=FALSE)
persp(x=1:20,y=1:20,z=as.matrix(ztab))
# check scala generation
persp(x=1:20,y=1:20,z=as.matrix(read.csv("tmp/pop_15764867352.csv",sep=";",header=FALSE)))


# now get configs and convert

prefix=paste0(Sys.getenv("CN_HOME"),'/Results/Synthetic/Density/Output/ScalaImpl/20150729_Scala_SamplingLHS/')

for(r in 1:nrow(representatives)){
  ztab=read.csv(paste0(prefix,'pop/pop_',fileName(representatives[r,]),".csv"),sep=";",header=FALSE)
  x=c();y=c();z=c();
  for(i in 1:nrow(ztab)){
    for(j in 1:ncol(ztab)){
      x=append(x,i);y=append(y,j);
      z=append(z,ztab[i,j])
    }
  }
  write.csv(data.frame(x=x,y=y,z=z),file=paste0(prefix,'processed/',fileName(representatives[r,]),'_config.csv'),row.names = FALSE)
  write.csv(data.frame(t(as.matrix(representatives[r,]))),file=paste0(prefix,'processed/',fileName(representatives[r,]),'_params.csv'),row.names = FALSE)
}



