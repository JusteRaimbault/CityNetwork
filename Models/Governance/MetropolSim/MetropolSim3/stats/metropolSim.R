
# Analysis of results of exploration for MetropolSim model

library(ggplot2)
source(paste0(Sys.getenv("CN_HOME"),'/Models/Utils/R/plots.R'))


res <- read.csv('Models/Governance/MetropolSim/MetropolSim3/res_oml/2015_08_17_02_38_36_lhsgrid.csv',sep=",",header=TRUE)
raw = getSingleParamPoints(
  data = res,
  params_cols = c(3,4,6,8,9,11,12,14,18),
  indics_cols = c(1,2,5,7,10,13,15,16,17)
)

param=matrix(data=unlist(raw$param),ncol=3,byrow=TRUE)
mean=matrix(data=unlist(raw$mean),ncol=4,byrow=TRUE)
sd=matrix(data=unlist(raw$sd),ncol=4,byrow=TRUE)


plotWithBars<-function(param,mean,sd,fixed_par_cols,fixed_par_vals,indicator,x_param,varying_param,xlab="",ylab="",xlim=c(0,1)){
  # get concerned rows
  rows=rep(TRUE,nrow(param))
  for(k in 1:length(fixed_par_cols)){rows=rows&(abs(param[,fixed_par_cols[k]]-fixed_par_vals[k])<0.0000001); }
  p=ggplot(data.frame(x=param[rows,x_param],y=mean[rows,indicator],regdecision=param[rows,varying_param],
                      ymin=mean[rows,indicator]-sd[rows,indicator],ymax=mean[rows,indicator]+sd[rows,indicator]),
           aes(x=x,y=y,colour=regdecision))
  p+geom_point()+geom_errorbar(aes(x=x,ymin=ymin,ymax=ymax),width=0.005)+xlab(xlab)+ylab(ylab)
  #+xlim(xlim)
}

indics=c("accessibility","entropy","stability","travel-distance")
plotlist=list();
for(i in 1:length(indics)){
plotlist[[i]]=plotWithBars(
  param,mean,sd,
  fixed_par_cols=c(1),fixed_par_vals=c(2.5),
  indicator=i,x_param=2,varying_param=3,
  xlab="lambda_acc",ylab=indics[i]#,xlim=c(0.25,1.25)
)
}

multiplot(plotlist=plotlist,cols=2)







