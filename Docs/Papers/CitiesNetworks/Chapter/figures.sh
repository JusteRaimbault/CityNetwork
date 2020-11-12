
RESDIR=$CN_HOME/Results/MacroCoevol/Exploration/20170926_GRID_VIRTUAL/targeted
PDFRESOLUTION=200
WIDTH=2000
HORIZONTALPADDING=10
VERTICALPADDING=10
JPGQUALITY=70

# Fig 1
cp figuresraw/model.pdf figures/Fig1.pdf
#convert -density $PDFRESOLUTION figuresraw/model.pdf -resize "$WIDTH"x -quality $JPGQUALITY figures/Fig1.jpg

# Fig 2
montage "$RESDIR"/closenessSummaries_mean_synthRankSize1_gravityWeight0_001_gravityDecay10_GREYSCSALE.png "$RESDIR"/populationEntropies_synthRankSize1_gravityWeight0_001_gravityGamma0_5_GREYSCALE.png -tile 1x2 -geometry +0+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY figures/Fig2.jpg

# Fig 3
montage "$RESDIR"/complexityAccessibility_synthrankSize1_nwGmax0_05_gravityWeight0_001_GREYSCALE.png "$RESDIR"/rankCorrAccessibility_synthrankSize1_nwGmax0_05_gravityWeight0_001_GREYSCALE.png -tile 1x2 -geometry +0+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY figures/Fig3.jpg

# Fig 4
convert "$RESDIR"/laggedregimes_absrho_nwGmax0_05_GREYSCALE.png -resize "$WIDTH"x -quality $JPGQUALITY figures/Fig4.jpg

# Fig 5
EMPIRICALRESDIR=$CN_HOME/Results/SpatioTempCausality/France
convert -density $PDFRESOLUTION "$EMPIRICALRESDIR"/significantcorrs_Ncities50_Tw_GREYSCALE.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY figures/significantcorrs_Tw.jpg
convert -density $PDFRESOLUTION "$EMPIRICALRESDIR"/significantcorrs_Ncities50_d0_GREYSCALE.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY figures/significantcorrs_d0.jpg
convert -density $PDFRESOLUTION "$EMPIRICALRESDIR"/laggedCorrs_time_Ncities50_Tw4_GREYSCALE.pdf -resize "$WIDTH"x -quality $JPGQUALITY figures/laggedCorrs_time_Tw4.jpg
montage figures/significantcorrs_Tw.jpg figures/significantcorrs_d0.jpg -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 -quality $JPGQUALITY figures/Fig5_tmp.jpg
montage figures/Fig5_tmp.jpg figures/laggedCorrs_time_Tw4.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY figures/Fig5.jpg
rm figures/significantcorrs_Tw.jpg figures/significantcorrs_d0.jpg figures/laggedCorrs_time_Tw4.jpg figures/Fig5_tmp.jpg
#convert figuresraw/6-2-3-fig-macrocoevol-empirical.jpg -set colorspace Gray figures/Fig5.jpg
# note: could have done that for all figures, but better for reproducibility to recreate figures from data?
# ! conversion is bad - recompute correlations

CALIBRESDIR=$CN_HOME/Results/MacroCoevol/Calibration/20171122_calibperiod_island_abstractnw_grid
# Fig 6
convert -density $PDFRESOLUTION "$CALIBRESDIR"/pareto_nwGmax_filtTRUE_GREYSCALE.pdf -resize "$WIDTH"x -quality $JPGQUALITY figures/Fig6.jpg

# Fig 7
montage "$CALIBRESDIR"/param_growthRate_filt1_GREYSCALE.png "$CALIBRESDIR"/param_gravityWeight_filt1_GREYSCALE.png "$CALIBRESDIR"/param_gravityDecay_filt1_GREYSCALE.png  "$CALIBRESDIR"/param_gravityGamma_filt1_GREYSCALE.png "$CALIBRESDIR"/param_nwThreshold_filt1_GREYSCALE.png "$CALIBRESDIR"/param_nwGmax_filt1_GREYSCALE.png -tile 3x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" figures/Fig7_tmp.png
convert figures/Fig7_tmp.png -resize "$WIDTH"x -quality $JPGQUALITY figures/Fig7.jpg
rm figures/Fig7_tmp.png


# Fig 8
convert $CN_HOME/Results/MacroCoEvol/Examples/example_slimemould_1_t0.png -set colorspace Gray -resize "$((WIDTH / 2))"x -quality $JPGQUALITY figures/example_slimemould_1_t0.jpg
convert $CN_HOME/Results/MacroCoEvol/Examples/example_slimemould_1_tf.png -set colorspace Gray -resize "$((WIDTH / 2))"x -quality $JPGQUALITY figures/example_slimemould_1_tf.jpg
montage figures/example_slimemould_1_t0.jpg figures/example_slimemould_1_tf.jpg -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 figures/Fig8.jpg
rm figures/example_slimemould_1_t0.jpg figures/example_slimemould_1_tf.jpg
