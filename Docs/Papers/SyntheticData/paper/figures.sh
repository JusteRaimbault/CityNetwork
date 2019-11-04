HEIGHT=2000
WIDTH=3000
HORIZONTALPADDING=1
VERTICALPADDING=1

# graphical abstract
montage $CS_HOME/FinancialNetwork/SyntheticAsset/Results/Stylized/filteringExample_20151101_10-30min.png $CS_HOME/CityNetwork/Results/Synthetic/Network/20160106_LHSDensityNW/res/configs/4_param71945_seed0.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize x"$HEIGHT" graphicalAbstract.png

# figure 1
FIGDIR=$CS_HOME/CityNetwork/Results/Synthetic/Network/20160106_LHSDensityNW/res/configs
montage $FIGDIR/1_param71861_seed0.png $FIGDIR/2_param71913_seed10.png $FIGDIR/3_param71918_seed0.png $FIGDIR/4_param71945_seed0.png -tile 2x2 -geometry +10+10 -resize "$((WIDTH/2))"x figures/Fig1.png

# figure 2
FIGDIR=$CS_HOME/CityNetwork/Results/Synthetic/Network/20160106_LHSDensityNW/res/crosscor
montage $FIGDIR/heatmap_max-abs-corr.png $FIGDIR/heatmap_amplitude.png -tile 1x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize x"$((HEIGHT/2))" tmp2_1.png
montage -resize x"$HEIGHT" $FIGDIR/hist_crossCorMat_breaks30.png tmp2_1.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" tmp2_2.png
montage $FIGDIR/pca_meanAbsCor_errorBars.png $FIGDIR/pca_realDistCol_meanAbsCorSize_withSpecificPoints.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize "$WIDTH"x tmp2_3.png
montage -resize x"$((WIDTH/2))" tmp2_2.png tmp2_3.png -tile 1x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize "$WIDTH"x figures/Fig2.png
rm tmp2_1.png tmp2_2.png tmp2_3.png

# figure 3
convert $CS_HOME/FinancialNetwork/SyntheticAsset/Results/Stylized/filteringExample_20151101_10-30min.png -resize "$WIDTH"x figures/Fig3.png

# figure 4
convert $CS_HOME/FinancialNetwork/SyntheticAsset/Results/Cors/effectiveCorrs.png -resize "$WIDTH"x figures/Fig4.png

# figure 5
montage $CS_HOME/FinancialNetwork/SyntheticAsset/Results/Prediction/predictionPerformance-rhoeff_filt6.png $CS_HOME/FinancialNetwork/SyntheticAsset/Results/Prediction/predictionPerformance-rhoeff_filt9.png $CS_HOME/FinancialNetwork/SyntheticAsset/Results/Prediction/predictionPerformance-rhoeff_filt12.png $CS_HOME/FinancialNetwork/SyntheticAsset/Results/Prediction/laggedCorrelations.png -resize "$((WIDTH/2))"x -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" figures/Fig5.png
