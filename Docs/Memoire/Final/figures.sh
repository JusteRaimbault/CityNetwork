
###############
## Figures

TARGET=$1

# general
FIGDIR=Figures/Final

# quality
JPGQUALITY=50
PDFRESOLUTION=200

# size parameters
WIDTH=2000
HORIZONTALPADDING=10
VERTICALPADDING=10

## Setup

mkdir $FIGDIR


###############
## Chapitre 1

if [ "$TARGET" == "--1" ] || [ "$TARGET" == "--all" ]
then

  ###############
  ## 1.2 : Case studies

  #fig:casestudies:gpe
  FIGNAME=1-2-1-fig-casestudies-gpe
  echo $FIGNAME
  convert Figures/CaseStudies/timeaccess_metropole.png -resize "$WIDTH"x -quality $JPGQUALITY Figures/CaseStudies/timeaccess_metropole.jpg
  convert Figures/CaseStudies/timegain_metropole.png -resize "$WIDTH"x -quality $JPGQUALITY Figures/CaseStudies/timegain_metropole.jpg
  montage Figures/CaseStudies/timeaccess_metropole.png Figures/CaseStudies/timegain_metropole.png -tile 1x2 -geometry +0+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:casestudies:projects
  FIGNAME=1-2-1-fig-casestudies-projects
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/GrandParisRealEstate/reseaux.pdf -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:casestudies:projects
  FIGNAME=1-2-1-fig-casestudies-empiricalres
  echo $FIGNAME
  convert Figures/GrandParisRealEstate/laggedcorrs_times_allvars.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  ###############
  ## 1.3 : Qualitative

  # fig:qualitative:hsr
  FIGNAME=1-3-1-fig-qualitative-hsr
  echo $FIGNAME
  montage Figures/Qualitative/tangjia.jpg Figures/Qualitative/zhuhai.jpg Figures/Qualitative/yangshuo.jpg Figures/Qualitative/chengdu.jpg -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:qualitative:schema
  #  schema is light, pdf ok





fi


###############
## Chapitre 2

if [ "$TARGET" == "--2" ] || [ "$TARGET" == "--all" ]
then

  ###############
  ## 2.2 : Quant Epistemo

  # fig:quantepistemo:interdisc
  FIGNAME=2-2-2-fig-quantepistemo-interdisc
  echo $FIGNAME
  convert Figures/QuantEpistemo/interdisciplinarities.png -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/QuantEpistemo/interdisciplinarities.jpg
  convert Figures/QuantEpistemo/compo_proportion.png -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/QuantEpistemo/compo_proportion.jpg
  convert Figures/QuantEpistemo/citation_proximities.png -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/QuantEpistemo/citation_proximities.jpg
  convert Figures/QuantEpistemo/semantic_proximities.png -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/QuantEpistemo/semantic_proximities.jpg
  montage Figures/QuantEpistemo/interdisciplinarities.jpg Figures/QuantEpistemo/compo_proportion.jpg Figures/QuantEpistemo/citation_proximities.jpg Figures/QuantEpistemo/semantic_proximities.jpg -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/QuantEpistemo/interdisciplinarities.jpg Figures/QuantEpistemo/compo_proportion.jpg Figures/QuantEpistemo/citation_proximities.jpg Figures/QuantEpistemo/semantic_proximities.jpg




fi


###############
## Chapitre 4

if [ "$TARGET" == "--4" ] || [ "$TARGET" == "--all" ]
then

  ###############
  ## 4.1 : Static Correlations

  # fig:staticcorrelations:empirical
  FIGNAME=4-1-1-fig-staticcorrelations-empirical
  echo $FIGNAME
  convert Figures/Density/Fig1.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:staticcorrs:network
  FIGNAME=4-1-2-fig-staticcorrs-network
  echo $FIGNAME
  convert Figures/StaticCorrelations/FR_indics_network_selected_2_discrquantiles.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:staticcorrs:mapscorrs
  FIGNAME=4-1-3-fig-staticcorrs-mapscorrs
  echo $FIGNAME
  montage Figures/StaticCorrelations/FR_corr_meanBetweenness_slope_rhoasize12.png Figures/StaticCorrelations/FR_corr_PCA_rhoasize12.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 $FIGDIR/"$FIGNAME".png
  convert $FIGDIR/"$FIGNAME".png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME".png

  # fig:staticcorrs:corrsdistrib
  FIGNAME=4-1-3-fig-staticcorrs-corrsdistrib
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/StaticCorrelations/corrs-distrib_varyingdelta_bytype.pdf -quality $JPGQUALITY Figures/StaticCorrelations/corrs-distrib_varyingdelta_bytype.jpg
  convert -density $PDFRESOLUTION Figures/StaticCorrelations/corrs-summary-meanabs_varyingdelta_bytype.pdf -quality $JPGQUALITY Figures/StaticCorrelations/corrs-summary-meanabs_varyingdelta_bytype.jpg
  montage Figures/StaticCorrelations/corrs-distrib_varyingdelta_bytype.jpg Figures/StaticCorrelations/corrs-summary-meanabs_varyingdelta_bytype.jpg -resize "$WIDTH"x -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 $FIGDIR/fig-staticcorrs-corrsdistrib_tmp1.jpg
  rm Figures/StaticCorrelations/corrs-distrib_varyingdelta_bytype.jpg;rm Figures/StaticCorrelations/corrs-summary-meanabs_varyingdelta_bytype.jpg
  convert Figures/Final/fig-staticcorrs-corrsdistrib_tmp1.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/fig-staticcorrs-corrsdistrib_tmp2.jpg
  convert -density $PDFRESOLUTION Figures/StaticCorrelations/normalized_CI_delta.pdf -quality $JPGQUALITY Figures/StaticCorrelations/normalized_CI_delta.jpg
  convert Figures/StaticCorrelations/scatter_meanabs_colcross.png -quality $JPGQUALITY Figures/StaticCorrelations/scatter_meanabs_colcross.jpg
  montage Figures/StaticCorrelations/normalized_CI_delta.jpg Figures/StaticCorrelations/scatter_meanabs_colcross.jpg -resize "$WIDTH"x -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 $FIGDIR/fig-staticcorrs-corrsdistrib_tmp3.jpg
  rm Figures/StaticCorrelations/normalized_CI_delta.jpg;rm Figures/StaticCorrelations/scatter_meanabs_colcross.jpg
  convert Figures/Final/fig-staticcorrs-corrsdistrib_tmp3.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/fig-staticcorrs-corrsdistrib_tmp4.jpg
  montage Figures/Final/fig-staticcorrs-corrsdistrib_tmp2.jpg Figures/Final/fig-staticcorrs-corrsdistrib_tmp4.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/Final/fig-staticcorrs-corrsdistrib_tmp1.jpg;rm Figures/Final/fig-staticcorrs-corrsdistrib_tmp2.jpg;rm Figures/Final/fig-staticcorrs-corrsdistrib_tmp3.jpg;rm Figures/Final/fig-staticcorrs-corrsdistrib_tmp4.jpg

  ###############
  ## 4.2 : Spatio-temp causalities

  # fig:causalityregimes:exrdb
  FIGNAME=4-2-2-fig-causalityregimes-exrdb
  echo $FIGNAME
  convert Figures/CausalityRegimes/laggedcorrs_facetextreme.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/laggedcorrs_facetextreme.jpg
  montage Figures/CausalityRegimes/ex_60_wdens0_wroad1_wcenter1_seed272727.png Figures/CausalityRegimes/ex_60_wdens1_wroad1_wcenter0_seed272727.png Figures/CausalityRegimes/ex_60_wdens1_wroad1_wcenter1_seed272727.png -tile 3x1 -geometry +"$HORIZONTALPADDING"+0 Figures/Final/fig-causalityregimes-exrdb_tmp.png
  convert Figures/Final/fig-causalityregimes-exrdb_tmp.png -resize "$WIDTH"x -quality $JPGQUALITY Figures/Final/fig-causalityregimes-exrdb_tmp.jpg
  rm $FIGDIR/fig-causalityregimes-exrdb_tmp.png
  montage Figures/Final/fig-causalityregimes-exrdb_tmp.jpg Figures/Final/laggedcorrs_facetextreme.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/fig-causalityregimes-exrdb_tmp.jpg
  rm $FIGDIR/laggedcorrs_facetextreme.jpg


  # fig:causalityregimes:clustering
  FIGNAME=4-2-2-fig-causalityregimes-clustering
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/CausalityRegimes/ccoef-knum_valuesFALSE_theta05-3.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/CausalityRegimes/ccoef-knum_valuesFALSE_theta05-3.jpg
  convert -density $PDFRESOLUTION Figures/CausalityRegimes/dccoef-knum_valuesFALSEtheta05-3.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/CausalityRegimes/dccoef-knum_valuesFALSEtheta05-3.jpg
  convert Figures/CausalityRegimes/clusters-PCA-features_valuesFALSEtheta2_k6.png -quality $JPGQUALITY Figures/CausalityRegimes/clusters-PCA-features_valuesFALSEtheta2_k6.jpg
  convert Figures/CausalityRegimes/clusters-paramfacet_valuesFALSEtheta2_k6.png -quality $JPGQUALITY Figures/CausalityRegimes/clusters-paramfacet_valuesFALSEtheta2_k6.jpg
  convert Figures/CausalityRegimes/clusters-centertrajs-facetclust_valuesFALSEtheta2_k6.png -resize "$WIDTH"x -quality $JPGQUALITY Figures/CausalityRegimes/clusters-centertrajs-facetclust_valuesFALSEtheta2_k6.jpg
  montage Figures/CausalityRegimes/ccoef-knum_valuesFALSE_theta05-3.jpg Figures/CausalityRegimes/dccoef-knum_valuesFALSEtheta05-3.jpg -tile 2x1 -geometry +0+"$HORIZONTALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/fig-causalityregimes-clustering_tmp1.jpg
  montage Figures/CausalityRegimes/clusters-PCA-features_valuesFALSEtheta2_k6.jpg Figures/CausalityRegimes/clusters-paramfacet_valuesFALSEtheta2_k6.jpg -tile 2x1 -geometry +0+"$HORIZONTALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/fig-causalityregimes-clustering_tmp2.jpg
  convert $FIGDIR/fig-causalityregimes-clustering_tmp1.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/fig-causalityregimes-clustering_tmp3.jpg
  convert $FIGDIR/fig-causalityregimes-clustering_tmp2.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/fig-causalityregimes-clustering_tmp4.jpg
  montage $FIGDIR/fig-causalityregimes-clustering_tmp3.jpg $FIGDIR/fig-causalityregimes-clustering_tmp4.jpg Figures/CausalityRegimes/clusters-centertrajs-facetclust_valuesFALSEtheta2_k6.jpg -tile 1x3 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/CausalityRegimes/ccoef-knum_valuesFALSE_theta05-3.jpg;rm Figures/CausalityRegimes/dccoef-knum_valuesFALSEtheta05-3.jpg;rm Figures/CausalityRegimes/clusters-PCA-features_valuesFALSEtheta2_k6.jpg;rm Figures/CausalityRegimes/clusters-paramfacet_valuesFALSEtheta2_k6.jpg;rm Figures/CausalityRegimes/clusters-centertrajs-facetclust_valuesFALSEtheta2_k6.jpg
  rm $FIGDIR/fig-causalityregimes-clustering_tmp1.jpg;rm $FIGDIR/fig-causalityregimes-clustering_tmp2.jpg;rm $FIGDIR/fig-causalityregimes-clustering_tmp3.jpg;rm $FIGDIR/fig-causalityregimes-clustering_tmp4.jpg

  # fig:causalityregimes:network
  FIGNAME=4-2-3-fig-causalityregimes-network
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/CausalityRegimes/nw_nwSize.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/CausalityRegimes/nw_nwSize.jpg
  convert -density $PDFRESOLUTION Figures/CausalityRegimes/nw_meanCentralities.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/CausalityRegimes/nw_meanCentralities.jpg
  convert -density $PDFRESOLUTION Figures/CausalityRegimes/nw_hierarchies.pdf -resize "$((WIDTH + 100))"x -quality $JPGQUALITY Figures/CausalityRegimes/nw_hierarchies.jpg
  convert -density $PDFRESOLUTION Figures/CausalityRegimes/nw_efficiency.pdf -resize "$((WIDTH - 100))"x -quality $JPGQUALITY Figures/CausalityRegimes/nw_efficiency.jpg
  montage Figures/CausalityRegimes/nw_nwSize.jpg Figures/CausalityRegimes/nw_meanCentralities.jpg Figures/CausalityRegimes/nw_hierarchies.jpg Figures/CausalityRegimes/nw_efficiency.jpg -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME"_tmp.jpg
  convert $FIGDIR/"$FIGNAME"_tmp.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/CausalityRegimes/nw_nwSize.jpg Figures/CausalityRegimes/nw_meanCentralities.jpg Figures/CausalityRegimes/nw_hierarchies.jpg Figures/CausalityRegimes/nw_efficiency.jpg $FIGDIR/"$FIGNAME"_tmp.jpg

  # fig:causalityregimes:sudafcorrs
  FIGNAME=4-2-3-fig-causalityregimes-sudafcorrs
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/CausalityRegimes/meanabscorrs.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/CausalityRegimes/meanabscorrs.jpg
  convert -density $PDFRESOLUTION Figures/CausalityRegimes/significantcorrs.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/CausalityRegimes/significantcorrs.jpg
  convert -density $PDFRESOLUTION Figures/CausalityRegimes/laggedCorrs_Tw3.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/CausalityRegimes/laggedCorrs_Tw3.jpg
  montage Figures/CausalityRegimes/meanabscorrs.jpg Figures/CausalityRegimes/significantcorrs.jpg -tile 2x1 -geometry +0+"$HORIZONTALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME"_tmp.jpg
  montage $FIGDIR/"$FIGNAME"_tmp.jpg Figures/CausalityRegimes/laggedCorrs_Tw3.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME"_tmp.jpg Figures/CausalityRegimes/meanabscorrs.jpg Figures/CausalityRegimes/significantcorrs.jpg Figures/CausalityRegimes/laggedCorrs_Tw3.jpg



  ###############
  ## 4.3 : Interaction Gibrat

  # fig:interactiongibrat:ts-correlations
  FIGNAME=4-3-2-fig-interactiongibrat-ts-correlations
  echo $FIGNAME
  convert Figures/InteractionGibrat/Fig1.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:interactiongibrat:interface
  FIGNAME=4-3-2-fig-interactiongibrat-interface
  echo $FIGNAME
  convert Figures/InteractionGibrat/Fig2.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:interactiongibrat:networkeffects
  FIGNAME=4-3-2-fig-interactiongibrat-networkeffects
  echo $FIGNAME
  convert Figures/InteractionGibrat/Fig3.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:interactiongibrat:gravity-pareto
  FIGNAME=4-3-2-fig-interactiongibrat-gravity-pareto
  echo $FIGNAME
  convert Figures/InteractionGibrat/Fig4.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:interactiongibrat:gravity-params
  FIGNAME=4-3-2-fig-interactiongibrat-gravity-params
  echo $FIGNAME
  convert Figures/InteractionGibrat/Fig5.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:interactiongibrat:feedback
  FIGNAME=4-3-2-fig-interactiongibrat-feedback
  echo $FIGNAME
  convert Figures/InteractionGibrat/Fig6.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg




fi






###############
## Chapitre 5

if [ "$TARGET" == "--5" ] || [ "$TARGET" == "--all" ]
then


###############
## 5.2 : Density Morphogenesis

FIGNAME=5-2-2-fig-density-fig2
echo $FIGNAME
convert Figures/Density/Fig2.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

FIGNAME=5-2-2-fig-density-fig3
echo $FIGNAME
convert Figures/Density/Fig3.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

FIGNAME=5-2-2-fig-density-fig4
echo $FIGNAME
convert Figures/Density/Fig4.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

FIGNAME=5-2-2-fig-density-fig5
echo $FIGNAME
convert Figures/Density/Fig5.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

FIGNAME=5-2-2-fig-density-fig6
echo $FIGNAME
convert Figures/Density/Fig6.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

###############
## 5.3 : Correlated Synthetic Data


# fig:correlatedsyntheticdata:densnwcor
FIGNAME=5-3-2-fig-correlatedsyntheticdata-densnwcor
echo $FIGNAME
convert -density $PDFRESOLUTION Figures/CorrelatedSyntheticData/hist_crossCorMat_breaks30.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/CorrelatedSyntheticData/hist_crossCorMat_breaks30.jpg
convert -density $PDFRESOLUTION Figures/CorrelatedSyntheticData/pca_meanAbsCor_errorBars.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/CorrelatedSyntheticData/pca_meanAbsCor_errorBars.jpg
montage Figures/CorrelatedSyntheticData/hist_crossCorMat_breaks30.jpg Figures/CorrelatedSyntheticData/pca_meanAbsCor_errorBars.jpg -tile 2x1 -geometry +0+"$HORIZONTALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME"_tmp1.jpg
convert Figures/CorrelatedSyntheticData/heatmaps.png -resize "$((WIDTH / 3))"x -quality $JPGQUALITY Figures/CorrelatedSyntheticData/heatmaps.jpg
convert Figures/CorrelatedSyntheticData/pca_realDistCol_meanAbsCorSize_withSpecificPoints.png -resize "$((2 * WIDTH / 3))"x -quality $JPGQUALITY Figures/CorrelatedSyntheticData/pca_realDistCol_meanAbsCorSize_withSpecificPoints.jpg
montage Figures/CorrelatedSyntheticData/heatmaps.jpg Figures/CorrelatedSyntheticData/pca_realDistCol_meanAbsCorSize_withSpecificPoints.jpg -tile 2x1 -geometry +0+"$HORIZONTALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME"_tmp2.jpg
montage $FIGDIR/"$FIGNAME"_tmp1.jpg $FIGDIR/"$FIGNAME"_tmp2.jpg -tile 1x2 -geometry +"$VERTICALPADDING"+0 -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
rm $FIGDIR/"$FIGNAME"_tmp2.jpg $FIGDIR/"$FIGNAME"_tmp1.jpg Figures/CorrelatedSyntheticData/pca_realDistCol_meanAbsCorSize_withSpecificPoints.jpg Figures/CorrelatedSyntheticData/heatmaps.jpg Figures/CorrelatedSyntheticData/pca_meanAbsCor_errorBars.jpg Figures/CorrelatedSyntheticData/hist_crossCorMat_breaks30.jpg


# fig:correlatedsyntheticdata:exampl
FIGNAME=5-3-2-fig-correlatedsyntheticdata-exampl
echo $FIGNAME
convert Figures/CorrelatedSyntheticData/configs/1_param71861_seed0.png -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/CorrelatedSyntheticData/configs/1_param71861_seed0.jpg
convert Figures/CorrelatedSyntheticData/configs/2_param71913_seed10.png -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/CorrelatedSyntheticData/configs/2_param71913_seed10.jpg
convert Figures/CorrelatedSyntheticData/configs/3_param71918_seed0.png -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/CorrelatedSyntheticData/configs/3_param71918_seed0.jpg
convert Figures/CorrelatedSyntheticData/configs/4_param71945_seed0.png -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/CorrelatedSyntheticData/configs/4_param71945_seed0.jpg
montage Figures/CorrelatedSyntheticData/configs/1_param71861_seed0.jpg Figures/CorrelatedSyntheticData/configs/2_param71913_seed10.jpg Figures/CorrelatedSyntheticData/configs/3_param71918_seed0.jpg Figures/CorrelatedSyntheticData/configs/4_param71945_seed0.jpg -tile 2x2 -geometry +"$VERTICALPADDING"+"$HORIZONTALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
rm Figures/CorrelatedSyntheticData/configs/1_param71861_seed0.jpg Figures/CorrelatedSyntheticData/configs/2_param71913_seed10.jpg Figures/CorrelatedSyntheticData/configs/3_param71918_seed0.jpg Figures/CorrelatedSyntheticData/configs/4_param71945_seed0.jpg









fi
