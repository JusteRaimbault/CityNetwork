
# empirical AIC

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/NetworkNecessity/InteractionGibrat'))

source('setup.R')


#####
# compare two models
#  M1 ; M2
#
#  corresponding to "optimal models" (heuristically fitted computational models)
#
#  M1 :
#  growthRate gravityWeight gravityGamma gravityDecay
#  0.01334922  0.0001287938      3.82252 401997651796
#
#  M2 : 
# growthRate gravityWeight gravityGamma gravityDecay feedbackWeight feedbackGamma feedbackDecay
#  0.01283191  0.0001308851     3.809335 8.434855e+14      0.6034981 1.148056  7.474787e+14

resM1=networkFeedbackModel(real_populations,distances,dists,dates,
                           growthRate = 0.01334922,
                           potentialWeight=0.0001287938,gammaGravity = 3.82252,decayGravity = 401997651796,
                           betaFeedback =0.0,feedbackDecay =  1.0  ,feedbackGamma = 0.0
)

logmse1 = log(sum((resM1$df$populations-resM1$df$real_populations)^2))
mselog1 = sum((log(resM1$df$populations)-log(resM1$df$real_populations))^2)

# iterative calib necessary here ?
resM2=networkFeedbackModel(real_populations,distances,dists,dates,
                     growthRate = 0.01283191,
                     potentialWeight=0.0001308851,gammaGravity = 3.809335,decayGravity = 8.434855e10,
                     betaFeedback =0.6034981,feedbackDecay = 7.474787e10  ,
                     feedbackGamma = 1.148056
                     )

logmse2 = log(sum((resM2$df$populations-resM2$df$real_populations)^2))
mselog2 = sum((log(resM2$df$populations)-log(resM2$df$real_populations))^2)

show(paste0('(1) : ',logmse1,' ; ',mselog1))
show(paste0('(2) : ',logmse2,' ; ',mselog2))



##
# Fit random statistical models with same parameter number

# no interaction models, to many parameters

X1=c();Y1=c()
X2=c();Y2=c()
for(j in 2:ncol(real_populations)){
  X1=append(X1,resM1$populations[,j-1]);Y1=append(Y1,resM1$populations[,j])
  X2=append(X2,resM2$populations[,j-1]);Y2=append(Y2,resM2$populations[,j])
}

# real data, to check performance of stat model alone
X1r=c();Y1r=c()
X2r=c();Y2r=c()
for(t in 2:max(resM1$df$times)){
  X1r=append(X1r,resM1$df$real_populations[resM1$df$times==t-1]);Y1r=append(Y1r,resM1$df$real_populations[resM1$df$times==t])
  X2r=append(X2r,resM2$df$real_populations[resM2$df$times==t-1]);Y2r=append(Y2r,resM2$df$real_populations[resM2$df$times==t])
}

#as.tbl(resM1$df)

#res1=nls(Y~X^a,data.frame(X,Y),start=list(a=1.5))

polFit<-function(data,params){
  form = "Y~a1+a2*X"
  start=list(a1=0,a2=0)
  for(k in 1:(params-2)){
    form=paste0(form,"+a",(k+2),"*X^",(k+1))
    start[[paste0("a",k+2)]]=0
  }
  statfit = nls(as.formula(form),data,start=start)
  return(statfit)
  #return(AIC(statfit))
}


p1 = polFit(data.frame(X=X1,Y=Y1),4)
p2 = polFit(data.frame(X=X2,Y=Y2),7)

AIC(p1) - AIC(p2) 
# = 19.65414

p1r = polFit(data.frame(X=X1r,Y=Y1r),4)
log(sum(summary(p1r)$residuals^2))

# test other types of non-linear models

p1 = polFit(data.frame(X=X1,Y=Y1),4)
est = summary(p1)$coefficients[1,1]+summary(p1)$coefficients[2,1]*X1+summary(p1)$coefficients[3,1]*X1^2+summary(p1)$coefficients[4,1]*X1^3
#plot(X1,Y1);points(X1,est,col='red')
log(sum((X1-Y1)^2))
log(sum((est-Y1)^2)) # = sum(summary(p1)$residuals^2)

# set the seed as GA ?
fit<-function(alpha){tryCatch({-sum(summary(nls(as.formula(paste0("Y~a1+a2*X^",alpha[1],"+a3*X^",alpha[2],"+a4*X^",alpha[3])),data.frame(X=X1,Y=Y1),start=list(a1=0,a2=0,a3=0,a4=0)))$residuals^2)},error = function(e) return(-1e15))}
optimnet = ga(type="real-valued",fitness = fit,min = c(0.0,0.0,0.0),max=c(10.0,10.0,10.0),maxiter = 1000,parallel=4)
sol = optimnet@solution
p1best = nls(as.formula(paste0("Y~a1+a2*X^",sol[1],"+a3*X^",sol[2],"+a4*X^",sol[3])),data.frame(X=X1,Y=Y1),start=list(a1=0,a2=0,a3=0,a4=0))

fit<-function(alpha){tryCatch({-sum(summary(nls(as.formula(paste0("Y~a1+a2*X^",alpha[1],"+a3*X^",alpha[2],"+a4*X^",alpha[3],"+a5*X^",alpha[4],"+a6*X^",alpha[5],"+a7*X^",alpha[6])),data.frame(X=X2,Y=Y2),start=list(a1=0,a2=0,a3=0,a4=0,a5=0,a6=0,a7=0)))$residuals^2)},error = function(e) return(-1e15))}
optimnet = ga(type="real-valued",fitness = fit,min = c(0.0,0.0,0.0,0.0,0.0,0.0),max=c(10.0,10.0,10.0,10.0,10.0,10.0),maxiter = 1000,parallel=4)
sol = optimnet@solution
p2best = nls(as.formula(paste0("Y~a1+a2*X^",sol[1],"+a3*X^",sol[2],"+a4*X^",sol[3],"+a5*X^",sol[4],"+a6*X^",sol[5],"+a7*X^",sol[6])),data.frame(X=X2,Y=Y2),start=list(a1=0,a2=0,a3=0,a4=0,a5=0,a6=0,a7=0))

AIC(p1best)-AIC(p2best)

# polynoms with larger degree ? -> ok included in power functions


# model with terms in log ?

nls(as.formula("Y~a1+a2*log(X)+a3*X+a4*X^2"),data.frame(X=X1,Y=Y1),start=list(a1=0,a2=0,a3=0,a4=0))










