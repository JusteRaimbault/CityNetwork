
library("poweRlaw")

data("moby", package = "poweRlaw")

# Discrete power law
pl_m <- displ$new(moby)
estimate_pars(pl_m)
est_pl <- estimate_xmin(pl_m)

pl_m$setXmin(est_pl)

dd <- plot(pl_m)
fitted <- lines(pl_m)


# parameter uncertainty
bs <- bootstrap(pl_m,xmins = seq(2, 20, 2), no_of_sims = 5000, threads = 4, seed = 1)


x = rpldis(100, xmin=2, alpha=3)

########################################################
##Continuous power law                                 #
########################################################
m1 = conpl$new(x)
m1$setXmin(estimate_xmin(m1))

########################################################
##Exponential           
########################################################
m2 = conexp$new(x)
m2$setXmin(m1$getXmin())
est2 = estimate_pars(m2)
m2$setPars(est2$pars)

########################################################
##Vuong's test                                         #
########################################################
comp = compare_distributions(m1, m2)
plot(comp)


