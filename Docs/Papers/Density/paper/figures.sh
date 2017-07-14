
# fig 1
montage figuresraw/cluster_pca_k5_morpho.png figuresraw/cluster_map_k5_morpho.png -tile 2x1 -geometry +40+5 figuresraw/fig1tmp.png
montage figuresraw/indics_morpho_discrquantiles.png figuresraw/fig1tmp.png -tile 1x2 -geometry +5+5 figures/Fig1.png
rm figuresraw/fig1tmp.png

# fig 2
montage figuresraw/ex_sp-diffusion\=0.05_sp-growth-rate\=76_sp-diffusion-steps\=2_sp-alpha-localization\=0.4_ticks\=995_sp-population\=75620.00000000015.png figuresraw/ex_sp-diffusion\=0.047_sp-growth-rate\=274_sp-diffusion-steps\=2_sp-alpha-localization\=1.4_ticks\=197_sp-population\=53977.999999999935.png figuresraw/ex_sp-diffusion\=0.0060_sp-growth-rate\=25_sp-diffusion-steps\=1_sp-alpha-localization\=0.4_ticks\=176_sp-population\=4400.000000000003.png figuresraw/ex_sp-diffusion\=0.0060_sp-growth-rate\=268_sp-diffusion-steps\=1_sp-alpha-localization\=1.6_ticks\=285_sp-population\=76376.00000000033.png -tile 2x2 -geometry +5+5 figures/Fig2.png

# fig 3
montage figuresraw/slope_alpha_diffsteps1_rate13-26.png figuresraw/slope_alpha_diffsteps4_rate41-78.png figuresraw/distance_alpha_diffsteps1_rate13-26.png figuresraw/distance_alpha_diffsteps4_rate41-78.png -tile 2x2 -geometry +5+5 figures/Fig3.png 

# fig 4


# fig 5
cp figuresraw/scaling_entropy_moran.png figures/Fig5.png

