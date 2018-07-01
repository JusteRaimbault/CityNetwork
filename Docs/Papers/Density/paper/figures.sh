

# fig 1
montage figuresraw/cluster_pca_k5_morpho.png figuresraw/cluster_map_k5_morpho.png -tile 2x1 -geometry +40+5 figuresraw/fig1tmp.png
montage figuresraw/indics_morpho_discrquantiles.png figuresraw/fig1tmp.png -tile 1x2 -geometry +5+5 figures/Fig2.png
rm figuresraw/fig1tmp.png

# Fig 2
convert -density 1000 figuresraw/flowchart.pdf -resize 2000 figures/Fig1.png


# fig 3
montage figuresraw/ex_sp-diffusion\=0.05_sp-growth-rate\=76_sp-diffusion-steps\=2_sp-alpha-localization\=0.4_ticks\=995_sp-population\=75620.00000000015.png figuresraw/ex_sp-diffusion\=0.047_sp-growth-rate\=274_sp-diffusion-steps\=2_sp-alpha-localization\=1.4_ticks\=197_sp-population\=53977.999999999935.png figuresraw/ex_sp-diffusion\=0.0060_sp-growth-rate\=25_sp-diffusion-steps\=1_sp-alpha-localization\=0.4_ticks\=176_sp-population\=4400.000000000003.png figuresraw/ex_sp-diffusion\=0.0060_sp-growth-rate\=268_sp-diffusion-steps\=1_sp-alpha-localization\=1.6_ticks\=285_sp-population\=76376.00000000033.png -tile 2x2 -geometry +5+5 figures/Fig3.png

# fig 4
montage figuresraw/slope_alpha_diffsteps1_rate13-26.png figuresraw/slope_alpha_diffsteps4_rate41-78.png figuresraw/distance_alpha_diffsteps1_rate13-26.png figuresraw/distance_alpha_diffsteps4_rate41-78.png -tile 2x2 -geometry +5+5 figures/Fig4.png

# fig 5
cp figuresraw/bifurcations.png figures/Fig5.png

# fig 6
montage figuresraw/pc_colalpha.png figuresraw/pc_colbeta.png -tile 2x1 -geometry +40+0 figuresraw/fig5tmp.png
montage figuresraw/fig5tmp.png figuresraw/synth.png -tile 1x2 -geometry +0+10 figures/Fig6.png
rm figuresraw/fig5tmp.png

# fig 7
cp figuresraw/scaling_entropy_moran.png figures/Fig7.png
