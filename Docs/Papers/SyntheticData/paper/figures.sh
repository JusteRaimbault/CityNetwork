HEIGHT=2000
WIDTH=3000
HORIZONTALPADDING=10
VERTICALPADDING=10

# graphical abstract
montage figuresraw/asset/ex_filtering.png figuresraw/configs/4_param71945_seed0.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize x"$HEIGHT" graphicalAbstract.png


# figure 1
convert $CS_HOME/FinancialNetwork/SyntheticAsset/Results/Stylized/filteringExample_20151101_10-30min.png -resize "$WIDTH"x figures/Fig1.png

# figure 2
convert $CS_HOME/FinancialNetwork/SyntheticAsset/Results/Cors/effectiveCorrs.png -resize "$WIDTH"x figures/Fig2.png

# figure 3
montage $CS_HOME/FinancialNetwork/SyntheticAsset/Results/Prediction/predictionPerformance-rhoeff_filt6.png $CS_HOME/FinancialNetwork/SyntheticAsset/Results/Prediction/predictionPerformance-rhoeff_filt9.png $CS_HOME/FinancialNetwork/SyntheticAsset/Results/Prediction/predictionPerformance-rhoeff_filt12.png $CS_HOME/FinancialNetwork/SyntheticAsset/Results/Prediction/laggedCorrelations.png -resize "$((WIDTH/2))"x -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" figures/Fig3.png
