
# Fig 1
cp figuresraw/empirical_tsCorrelations.png figures/Fig1.png

# Fig 2
montage figuresraw/exview_g0.0136_wg1.18e-4_ggamma1.87_gdecay307.1_wn0_RouenMarseille.png figuresraw/fits_g0.0136_wg1.18e-4_ggamma1.87_gdecay307.1_wn0_RouenMarseille.png -tile 2x1 -geometry +10+0 figures/Fig2.png 

# Fig 3
montage figuresraw/logmse-feedbackDecay_ZOOM.png figuresraw/mselog-feedbackDecay_ZOOM.png -tile 2x1 -geometry +10+0 figures/Fig3.png

# Fig 4
cp figuresraw/gravity.png figures/Fig4.png

# Fig 5
montage figuresraw/growthRate_filt1.png figuresraw/gravityWeight_filt1.png figuresraw/gravityDecay_filt1.png figuresraw/gravityGamma_filt1.png -tile 2x2 -geometry +10+10 figures/Fig5.png

# Fig 6
montage figuresraw/growthRate_filt0.png figuresraw/gravityWeight_relativegrowthRate.png figuresraw/feedbackDecay_filt0.png figuresraw/feedbackGamma_filt0.png -tile 2x2 -geometry +10+10 figures/Fig6.png

