
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









