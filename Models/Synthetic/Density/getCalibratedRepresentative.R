
# convert population grids obtained from calibration
# to a specific format

# get best params rows, param_values and indic_values from morpho_calib script
# best_params_rows = ...
# best_params = ...

best_params_rows = sample.int(6000,size=1000)

representatives = getRepresentatives(res,m,best_params_rows,params_cols,6:10,indics_cols[c(1,2,3,5)],indics_cols_m[c(1,2,3,5)])

#files<-list.files(paste0(Sys.getenv("CN_HOME"),'/Results/Synthetic/Density/Output/ScalaImpl/20150729_Scala_SamplingLHS/pop'))

#
# SHIT pb with fileNames, non integer diffusion steps.
# -> rename files
#     SHELL command in pop dir :
#         ls | awk -F"." '{print "echo "$2 "| mv "$1"."$2".csv "$1".`head -c 9`.csv"}' | sh
# -> rewrite function to take prefix (length 9) of diffsteps only.
#
fileName<-function(params){
  #return(paste0("pop/temp_pop_",params["population"],"_",params["diffusion"],"_",params["diffusionsteps"],
  #              "_",params["growthrate"],"_",params["alphalocalization"],"_",params["replication"],".csv"
  #              ))
  # -> DOES NOT WORK, ROUNDING ISSUES
  # use integer keys : rep and diffSteps
  #inds=sapply(files,function(s){grepl(paste0(params["replication"],".csv"),s)})&sapply(files,function(s){grepl(paste0("_",params["diffusionsteps"],"_"),s)})
  #return(files[inds])
  return(paste0(params["replication"],sprintf("%.9f",10^-9*floor(params["diffusionsteps"]*10^9))))
}

# test if the file exists
z=read.csv(fileName(representatives[1,c(params_cols,9)]),sep=";",header=FALSE)
z=read.csv(paste0("pop/",fileName(res[sample.int(nrow(res),1),c(params_cols,9)])),sep=";",header=FALSE)
persp(x=1:100,y=1:100,z=as.matrix(ztab))
# check scala generation
persp(x=1:20,y=1:20,z=as.matrix(read.csv("tmp/pop_15764867352.csv",sep=";",header=FALSE)))


# now get configs and convert

prefix=paste0(Sys.getenv("CN_HOME"),'/Results/Synthetic/Density/Output/ScalaImpl/20150806_Scala_SamplingLHS/')

#for(r in 1:nrow(representatives)){
xmax=c();ymax=c();
for(r in 1:nrow(representatives)){
  show(r)
  if(representatives[r,"moran"]>0.15){
  ztab=read.csv(paste0(prefix,'pop/pop_',fileName(representatives[r,]),".csv"),sep=";",header=FALSE)
  #show(which(ztab==max(ztab)))
  imax = which(ztab==max(ztab))
  xmax = append( xmax , floor(imax / 100));ymax = append(ymax , imax%%100)
  #x=c();y=c();z=c();
  persp(x=1:100,y=1:100,z=as.matrix(ztab))
  #for(i in 1:nrow(ztab)){
  #  for(j in 1:ncol(ztab)){
  #    x=append(x,i);y=append(y,j);
  #    z=append(z,ztab[i,j])
  #  }
  #}
  #write.csv(data.frame(x=x,y=y,z=z),file=paste0(prefix,'processed/',fileName(representatives[r,]),'_config.csv'),row.names = FALSE)
  #write.csv(data.frame(t(as.matrix(representatives[r,]))),file=paste0(prefix,'processed/',fileName(representatives[r,]),'_params.csv'),row.names = FALSE)
  }
}

summary(xmax);summary(ymax);
sd(xmax);sd(ymax)
