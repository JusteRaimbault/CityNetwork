
# empirical AIC

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/NetworkNecessity/InteractionGibrat'))

source('setup.R')


res=networkFeedbackModel(real_populations,distances,dists,
                     growthRate = 0.01,
                     potentialWeight=0.001,gammaGravity = 2.0,decayGravity = 2000
                     )

res$populations
