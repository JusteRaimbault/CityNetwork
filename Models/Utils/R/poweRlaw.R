
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


