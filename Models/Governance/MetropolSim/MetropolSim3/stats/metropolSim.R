
# Analysis of results of exploration for MetropolSim model

library(ggplot2)
source(paste0(Sys.getenv("CN_HOME"),'/Models/Utils/R/plots.R')) 


#res <- read.csv('Models/Governance/MetropolSim/MetropolSim3/res_oml/2015_08_17_02_38_36_lhsgrid.csv',sep=",",header=TRUE)
res <- read.csv('Models/Governance/MetropolSim/MetropolSim3/res_oml/2015_08_31_18_31_44_lhsgrid.csv',sep=",",header=TRUE)
res <- read.csv('Models/Governance/MetropolSim/MetropolSim3/res_oml/2015_09_01_21_46_14_targeted.csv',sep=",",header=TRUE)



params_cols = c(3,4,6,9,11,12,14,18)
indics_cols = c(1,2,5,7,8,10,13,15,16,17)

raw = getSingleParamPoints(
  data = res,
  params_cols = params_cols,
  indics_cols = indics_cols
)

param=matrix(data=unlist(raw$param),ncol=length(params_cols),byrow=TRUE);colnames(param)<-colnames(res)[params_cols]
mean=matrix(data=unlist(raw$mean),ncol=length(indics_cols),byrow=TRUE);colnames(mean)<-colnames(res)[indics_cols]
sd=matrix(data=unlist(raw$sd),ncol=length(indics_cols),byrow=TRUE);colnames(sd)<-colnames(res)[indics_cols]


plotWithBars<-function(param,mean,sd,fixed_par_cols,fixed_par_vals,fixed_par_thresholds,indicator,x_param,varying_param,xlab="",ylab="",xlim=c(0,1)){
  # get concerned rows
  rows=rep(TRUE,nrow(param))
  for(k in 1:length(fixed_par_cols)){rows=rows&(abs(param[,fixed_par_cols[k]]-fixed_par_vals[k])<fixed_par_thresholds[k]); }
  p=ggplot(data.frame(x=param[rows,x_param],
                      y=mean[rows,indicator],
                      group=param[rows,varying_param],
                      ymin=mean[rows,indicator]-sd[rows,indicator],
                      ymax=mean[rows,indicator]+sd[rows,indicator]),
           aes(x=x,y=y,colour=group))
  p+geom_point()+geom_errorbar(aes(x=x,ymin=ymin,ymax=ymax),width=0.005)+xlab(xlab)+ylab(ylab)
  return(p)
  #+xlim(xlim)
}

#indics=c("accessibility","entropy","stability","travel-distance")
indics=colnames(mean)
indics_cols_toplot = c(1,2,3,4,5,7,8,9,10)
plotlist=list();
for(i in indics_cols_toplot){
plotlist[[i]]=
  plotWithBars(
  param,mean,sd,
  fixed_par_cols=c(1,2,3,6,7,8),
  fixed_par_vals=c(2e-4,2e-3,3,5e-3,0.5,1),
  fixed_par_thresholds=c(1e-4,1e-3,1,1e-3,0.1,0.1),
  indicator=i,
  x_param=4,
  varying_param=5,
  xlab="lambda_acc",ylab=indics[i]#,xlim=c(0.25,1.25)
)+geom_point()+geom_errorbar(aes(x=x,ymin=ymin,ymax=ymax),width=0.005)
}

multiplot(plotlist=plotlist,cols=2)


#########
#m_rand = mean[param[,5]==1,];sd_rand=sd[param[,5]==1,];p_rand=param[param[,5]==1,]
#prefilter_rows = (param[,8]==2&param[,7]==0.5)
prefilter_rows = (param[,8]==2)
m_dc = mean[param[,5]==1&prefilter_rows,];sd_dc=sd[param[,5]==1&prefilter_rows,];p_dc=param[param[,5]==1&prefilter_rows,]
m_nash = mean[param[,5]==3&prefilter_rows,];sd_nash=sd[param[,5]==3&prefilter_rows,];p_nash=param[param[,5]==3&prefilter_rows,]

indics=colnames(mean)
indics_cols_toplot = c(1,2,3,4,5,7,8,9,10)


x_cols = c(1,2,3,4,6);xlabs=colnames(param)[x_cols]

for(p in 1:length(x_cols)){
  par(mfrow=c(3,3))
  x_col=x_cols[p];xlab=xlabs[p]
  for(i in indics_cols_toplot){
    boxplot(formula=y~f,data=data.frame(y=m_dc[,i],f=cut(p_dc[,x_col],breaks=10)),
            col="darkred",boxwex=0.5,main=indics[i],xlab=xlab)
    #plot(p_dc[,x_col],m_dc[,i],col="red",main=indics[i],
    #     xlim=c(min(p_dc[,x_col],p_nash[,x_col]),max(p_dc[,x_col],p_nash[,x_col])),
    #     ylim=c(min(m_dc[,i],m_nash[,i]),max(m_dc[,i],m_nash[,i])),
    #     xlab=xlab,ylab=""
    #);
    boxplot(formula=y~f,data=data.frame(y=m_nash[,i],f=cut(p_nash[,x_col],breaks=10))
            ,add=TRUE,col="darkgreen",boxwex=0.5,at=(1:10)+0.5,names=rep("",10))
    #points(p_nash[,x_col],m_nash[,i],col="green");
  }
}

#######################
#######################


# special plots : indics = f(k/J)

par(mfrow=c(3,3))
xlab="extgrowth / collcost"
for(i in indics_cols_toplot){
  boxplot(formula=y~f,data=data.frame(y=m_dc[,i],f=cut(p_dc[,4]/p_dc[,1],breaks=10)),
          col="darkred",boxwex=0.5,main=indics[i],xlab=xlab)
  #plot(p_dc[,x_col],m_dc[,i],col="red",main=indics[i],
  #     xlim=c(min(p_dc[,x_col],p_nash[,x_col]),max(p_dc[,x_col],p_nash[,x_col])),
  #     ylim=c(min(m_dc[,i],m_nash[,i]),max(m_dc[,i],m_nash[,i])),
  #     xlab=xlab,ylab=""
  #);
  boxplot(formula=y~f,data=data.frame(y=m_nash[,i],f=cut(p_nash[,4]/p_nash[,1],breaks=10))
          ,add=TRUE,col="darkgreen",boxwex=0.5,at=(1:10)+0.5,names=rep("",10))
  #points(p_nash[,x_col],m_nash[,i],col="green");
}




#####################
#####################
# QuickNDirty : heatmaps for 2D param space

#2015_09_01_21_46_14_targeted.csv

library(RColorBrewer)

par(mfrow=c(3,3))
prefilter_rows = (param[,8]==2&param[,5]==1)
plots=list()
for(i in indics_cols_toplot){
  indic=i
  
  #p=ggplot(data.frame(x=param[prefilter_rows,1],
  #                    y=param[prefilter_rows,4],
  #                    indic=mean[prefilter_rows,indic]),
  #         aes(x=x,y=y,colour=indic))
  #+geom_errorbar(aes(x=x,ymin=ymin,ymax=ymax),width=0.005)+xlab(xlab)+ylab(ylab)

  #plots[[i]]=p+geom_point()#+title(indics[i])
    
    
  plot(param[prefilter_rows,1],param[prefilter_rows,4],
     col=heat.colors(50)[50*(mean[prefilter_rows,indic]-min(mean[prefilter_rows,indic]))/(max(mean[prefilter_rows,indic])-min(mean[prefilter_rows,indic]))+1],
     pch=".",cex=40,xlab="collab",ylab="ext-growth",
     main=indics[i]
     )
}

#multiplot(plotlist=plots,cols=3)



