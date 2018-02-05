
# empirical AIC

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/InteractionGibrat'))

source('setup.R')

resmselog1 <- as.tbl(read.csv('calibration/20180203_gravitycalib_mselog/population4908.csv'))
resmselog2 <- as.tbl(read.csv('calibration/20180204_fullcalib_mselog/population4957.csv'))
reslogmse1 <- as.tbl(read.csv('calibration/20180203_gravitycalib_logmse/population4962.csv'))
reslogmse2 <- as.tbl(read.csv('calibration/20180205_fullcalib_logmse/population4897.csv'))


#####
# compare two models
#  M1 ; M2
#
#  corresponding to "optimal models" (heuristically fitted computational models)
#
#  M1 : 
#  growthRate gravityWeight gravityGamma gravityDecay mselog
#  [ old - 0.01334922  0.0001287938      3.82252 401997651796]
#   0.01332339 0.0002549774 4.956849 2.655547 0.01 299.1716
#
#  M2 : 
# growthRate gravityWeight gravityGamma gravityDecay feedbackWeight feedbackGamma feedbackDecay
#  [old - 0.01283191  0.0001308851     3.809335 8.434855e+14      0.6034981 1.148056  7.474787e+14]
#  0.01330867 0.0002152796 6.049928 2.207932 0.06647811 9.993359 0.01  298.5073

#logmses=c()
#for(gd in 1:40){
resM1=networkFeedbackModel(real_populations,distances,dists,dates,
                           growthRate = 0.01236603,
                           potentialWeight=0.0001695047,gammaGravity = 3.127771,decayGravity = 20000,
                           #potentialWeight=0.0001287938,gammaGravity = 3.046197,decayGravity = exp(gd),
                           betaFeedback =0.0,feedbackDecay =  1.0  ,feedbackGamma = 0.0
)

logmse1 = log(sum((resM1$df$populations-resM1$df$real_populations)^2));
mse1 = sum((resM1$df$populations-resM1$df$real_populations)^2)
mselog1 = sum((log(resM1$df$populations)-log(resM1$df$real_populations))^2);mselog1
#logmses=append(logmses,mselog1)
#}
#diff(logmses)

# iterative calib necessary here ?
#logmses=c()
#for(fd in seq(1,10000,100)){
#for(fw in seq(-5,0,1)){
resM2=networkFeedbackModel(real_populations,distances,dists,dates,
                     growthRate = 0.01230605,
                     potentialWeight=0.0001718408,gammaGravity = 3.197045,decayGravity = 20000,
                     betaFeedback =0.1616271,feedbackGamma = 8.234859,feedbackDecay = 0.01
                     )
logmse2 = log(sum((resM2$df$populations-resM2$df$real_populations)^2))
mse2 = sum((resM2$df$populations-resM2$df$real_populations)^2)
mselog2 = sum((log(resM2$df$populations)-log(resM2$df$real_populations))^2);mselog2
#logmses=append(logmses,mselog2)
#}
#plot(seq(1,10000,100),logmses,type='l')
#plot(seq(-5,0,1),logmses,type='l')


show(paste0('(1) : ',logmse1,' ; ',mselog1))
show(paste0('(2) : ',logmse2,' ; ',mselog2))


# 
n1=length(resM1$df$populations);k1=4
n2=length(resM2$df$populations);k2=7
(n1*log(mse1/n1) + 2*k1*n1/(n1-k1-1)) - (n2*log(mse2/n2) + 2*k2*n2/(n2-k2-1))
(n1*log(mse1/n1) + 2*k1) - (n2*log(mse2/n2) + 2*k2)
(n1*log(mselog1/n1) + 2*k1) - (n2*log(mselog2/n2) + 2*k2)
(n1*log(mselog1/n1) + 2*k1*n1/(n1-k1-1)) - (n2*log(mselog2/n2) + 2*k2*n2/(n2-k2-1))


n1*mselog1 + 2*k1*n1/(n1-k1-1)
n2*mselog2 + 2*k2*n2/(n2-k2-1)

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

sum(summary(p1)$residuals^2)/mse1
sum(summary(p2)$residuals^2)/mse2
AIC(p1) - AIC(p2) 
# = 19.65414
BIC(p1) - BIC(p2) 

## tests
n1=length(summary(p1)$residuals);k1=4
n2=length(summary(p2)$residuals);k2=7
(n1*log(sum(summary(p1)$residuals^2)/n1)+2*k1) - (n2*log(sum(summary(p2)$residuals^2)/n2)+2*k2)

AIC(p1) - AIC(p2) - n1*(log(sum(summary(p1)$residuals^2)/mse1)-log(sum(summary(p2)$residuals^2)/mse2))

###


p1 = nls(as.formula("Y~a1+a2*log(X)+a3*X+a4*X^2"),data.frame(X=X1,Y=Y1),start=list(a1=0,a2=0,a3=0,a4=0))
p2 = nls(as.formula("Y~a1+a2*log(X)+a3*X+a4*X^2+a5*X^3+a6*X^4+a7*X^5"),data.frame(X=X2,Y=Y2),start=list(a1=0,a2=0,a3=0,a4=0,a5=0,a6=0,a7=0))

sum(summary(p1)$residuals^2)/mse1
sum(summary(p2)$residuals^2)/mse2
AIC(p1) - AIC(p2) 
# = 19.65414
BIC(p1) - BIC(p2) 

AIC(p1) - AIC(p2) - n1*(log(sum(summary(p1)$residuals^2)/mse1)-log(sum(summary(p2)$residuals^2)/mse2))



p1r = polFit(data.frame(X=X1r,Y=Y1r),4)
log(sum(summary(p1r)$residuals^2))

# test other types of non-linear models

p1 = polFit(data.frame(X=X1,Y=Y1),4)
est = summary(p1)$coefficients[1,1]+summary(p1)$coefficients[2,1]*X1+summary(p1)$coefficients[3,1]*X1^2+summary(p1)$coefficients[4,1]*X1^3
#plot(X1,Y1);points(X1,est,col='red')
log(sum((X1-Y1)^2))
log(sum((est-Y1)^2)) # = sum(summary(p1)$residuals^2)

# set the seed as GA ?
set.seed(0)
fit<-function(alpha){tryCatch({-sum(summary(nls(as.formula(paste0("Y~a1+a2*X^",alpha[1],"+a3*X^",alpha[2],"+a4*X^",alpha[3])),data.frame(X=X1,Y=Y1),start=list(a1=0,a2=0,a3=0,a4=0)))$residuals^2)},error = function(e) return(-1e15))}
optimnet = ga(type="real-valued",fitness = fit,min = c(0.0,0.0,0.0),max=c(10.0,10.0,10.0),maxiter = 1000,parallel=4)
sol1 = optimnet@solution
p1best = nls(as.formula(paste0("Y~a1+a2*X^",sol1[1],"+a3*X^",sol1[2],"+a4*X^",sol1[3])),data.frame(X=X1,Y=Y1),start=list(a1=0,a2=0,a3=0,a4=0))

fit<-function(alpha){tryCatch({-sum(summary(nls(as.formula(paste0("Y~a1+a2*X^",alpha[1],"+a3*X^",alpha[2],"+a4*X^",alpha[3],"+a5*X^",alpha[4],"+a6*X^",alpha[5],"+a7*X^",alpha[6])),data.frame(X=X2,Y=Y2),start=list(a1=0,a2=0,a3=0,a4=0,a5=0,a6=0,a7=0)))$residuals^2)},error = function(e) return(-1e15))}
optimnet = ga(type="real-valued",fitness = fit,min = c(0.0,0.0,0.0,0.0,0.0,0.0),max=c(10.0,10.0,10.0,10.0,10.0,10.0),maxiter = 1000,parallel=4)
sol2 = optimnet@solution
p2best = nls(as.formula(paste0("Y~a1+a2*X^",sol2[1],"+a3*X^",sol2[2],"+a4*X^",sol2[3],"+a5*X^",sol2[4],"+a6*X^",sol2[5],"+a7*X^",sol2[6])),data.frame(X=X2,Y=Y2),start=list(a1=0,a2=0,a3=0,a4=0,a5=0,a6=0,a7=0))

save(sol1,sol2,file='res/aicga.RData')

sum(summary(p1best)$residuals^2)/mse1
sum(summary(p2best)$residuals^2)/mse2

AIC(p1best)-AIC(p2best)
# 11.70287
BIC(p1best)-BIC(p2best)
# -4.236787

AIC(p1) - AIC(p2) - (log(sum(summary(p1)$residuals^2)/mse1)-log(sum(summary(p2)$residuals^2)/mse2))


# polynoms with larger degree ? -> ok included in power functions


# model with terms in log ?

nls(as.formula("Y~a1+a2*log(X)+a3*X+a4*X^2"),data.frame(X=X1,Y=Y1),start=list(a1=0,a2=0,a3=0,a4=0))










