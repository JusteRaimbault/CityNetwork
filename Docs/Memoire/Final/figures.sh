
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
## Chapitre 3

if [ "$TARGET" == "--3" ] || [ "$TARGET" == "--all" ]
then

  ###############
  ## 3.1 : Modeling

  # fig:computation:sugarscape-distance
  FIGNAME=3-1-3-fig-computation-sugarscape-distance
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/Computation/relativedistance_metaparams.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/Computation/relativedistance_metaparams.jpg
  convert -density $PDFRESOLUTION Figures/Computation/relativedistance_morphspace.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/Computation/relativedistance_morphspace.jpg
  montage Figures/Computation/relativedistance_metaparams.jpg Figures/Computation/relativedistance_morphspace.jpg -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/Computation/relativedistance_metaparams.jpg Figures/Computation/relativedistance_morphspace.jpg

  # fig:computation:sugarscape-phasediagrams
  FIGNAME=3-1-3-fig-computation-sugarscape-phasediagrams
  echo $FIGNAME
  convert Figures/Computation/phasediagram_id27_maxSugar110.png -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/Computation/phasediagram_id27_maxSugar110.jpg
  convert Figures/Computation/phasediagram_id0_maxSugar110.png -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/Computation/phasediagram_id0_maxSugar110.jpg
  montage Figures/Computation/phasediagram_id27_maxSugar110.jpg Figures/Computation/phasediagram_id0_maxSugar110.jpg -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/Computation/phasediagram_id27_maxSugar110.jpg Figures/Computation/phasediagram_id0_maxSugar110.jpg



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




###############
## Chapitre 6

if [ "$TARGET" == "--6" ] || [ "$TARGET" == "--all" ]
then

  ###############
  ## 6.1 : Macro-coevol Exploration

  # fig:macrocoevolexplo:behavior
  FIGNAME=6-1-3-fig-macrocoevolexplo-behavior
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/MacroCoEvolExplo/closenessEntropies_networkGamma2_5_networkSpeed110.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvolExplo/closenessEntropies_networkGamma2_5_networkSpeed110.jpg
  convert -density $PDFRESOLUTION Figures/MacroCoEvolExplo/rankCorrPop_synthRankSize0_5_networkSpeed10.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvolExplo/rankCorrPop_synthRankSize0_5_networkSpeed10.jpg
  convert -density $PDFRESOLUTION Figures/MacroCoEvolExplo/distcorrs_networkGamma2_5_networkThreshold21_networkSpeed10.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvolExplo/distcorrs_networkGamma2_5_networkThreshold21_networkSpeed10.jpg
  convert -density $PDFRESOLUTION Figures/MacroCoEvolExplo/laggedcorrs_networkGamma2_5_networkThreshold21_networkSpeed10.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvolExplo/laggedcorrs_networkGamma2_5_networkThreshold21_networkSpeed10.jpg
  montage Figures/MacroCoEvolExplo/closenessEntropies_networkGamma2_5_networkSpeed110.jpg Figures/MacroCoEvolExplo/rankCorrPop_synthRankSize0_5_networkSpeed10.jpg Figures/MacroCoEvolExplo/distcorrs_networkGamma2_5_networkThreshold21_networkSpeed10.jpg Figures/MacroCoEvolExplo/laggedcorrs_networkGamma2_5_networkThreshold21_networkSpeed10.jpg -tile 2x2 -geometry +"$VERTICALPADDING"+"$HORIZONTALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/MacroCoEvolExplo/closenessEntropies_networkGamma2_5_networkSpeed110.jpg Figures/MacroCoEvolExplo/rankCorrPop_synthRankSize0_5_networkSpeed10.jpg Figures/MacroCoEvolExplo/distcorrs_networkGamma2_5_networkThreshold21_networkSpeed10.jpg Figures/MacroCoEvolExplo/laggedcorrs_networkGamma2_5_networkThreshold21_networkSpeed10.jpg

  ###############
  ## 6.2 : Macro-coevol

  # fig:macrocoevol:model
  # ok, very light pdf

  # fig:macrocoevol:behavior
  FIGNAME=6-2-2-fig-macrocoevol-behavior
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/closenessSummaries_mean_gravityWeight0_001.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvol/closenessSummaries_mean_gravityWeight0_001.jpg
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/populationEntropies_gravityWeight0_001.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvol/populationEntropies_gravityWeight0_001.jpg
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/complexityAccessibility_synthrankSize1_nwGmax0_05.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvol/complexityAccessibility_synthrankSize1_nwGmax0_05.jpg
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/rankCorrAccessibility_synthrankSize1_nwGmax0_05.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvol/rankCorrAccessibility_synthrankSize1_nwGmax0_05.jpg
  montage Figures/MacroCoEvol/closenessSummaries_mean_gravityWeight0_001.jpg Figures/MacroCoEvol/populationEntropies_gravityWeight0_001.jpg Figures/MacroCoEvol/complexityAccessibility_synthrankSize1_nwGmax0_05.jpg Figures/MacroCoEvol/rankCorrAccessibility_synthrankSize1_nwGmax0_05.jpg -tile 2x2 -geometry +"$VERTICALPADDING"+"$HORIZONTALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/MacroCoEvol/closenessSummaries_mean_gravityWeight0_001.jpg Figures/MacroCoEvol/populationEntropies_gravityWeight0_001.jpg Figures/MacroCoEvol/complexityAccessibility_synthrankSize1_nwGmax0_05.jpg Figures/MacroCoEvol/rankCorrAccessibility_synthrankSize1_nwGmax0_05.jpg

  # fig:macrocoevol:correlations
  FIGNAME=6-2-2-fig-macrocoevol-correlations
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/distcorrs_gravityWeight5e-04_nwThreshold4_5.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvol/distcorrs_gravityWeight5e-04_nwThreshold4_5.jpg
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/laggedcorrs_gravityWeight5e-04_nwThreshold4_5.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvol/laggedcorrs_gravityWeight5e-04_nwThreshold4_5.jpg
  montage Figures/MacroCoEvol/distcorrs_gravityWeight5e-04_nwThreshold4_5.jpg Figures/MacroCoEvol/laggedcorrs_gravityWeight5e-04_nwThreshold4_5.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/MacroCoEvol/distcorrs_gravityWeight5e-04_nwThreshold4_5.jpg Figures/MacroCoEvol/laggedcorrs_gravityWeight5e-04_nwThreshold4_5.jpg

  # fig:macrocoevol:pareto
  FIGNAME=6-2-3-fig-macrocoevol-pareto
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/pareto_gravityDecay.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvol/pareto_gravityDecay.jpg
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/pareto_nwThreshold.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvol/pareto_nwThreshold.jpg
  montage Figures/MacroCoEvol/pareto_gravityDecay.jpg Figures/MacroCoEvol/pareto_nwThreshold.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/MacroCoEvol/pareto_gravityDecay.jpg Figures/MacroCoEvol/pareto_nwThreshold.jpg

  # fig:macrocoevol:parameters
  FIGNAME=6-2-3-fig-macrocoevol-parameters
  echo $FIGNAME
  montage Figures/MacroCoEvol/param_gravityWeight_filt1.png Figures/MacroCoEvol/param_gravityDecay_filt1.png Figures/MacroCoEvol/param_gravityGamma_filt1.png Figures/MacroCoEvol/param_nwExponent_filt1.png Figures/MacroCoEvol/param_nwThreshold_filt1.png Figures/MacroCoEvol/param_nwGmax_filt1.png -tile 3x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" $FIGDIR/"$FIGNAME"_tmp.png
  convert $FIGDIR/"$FIGNAME"_tmp.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME"_tmp.png

  # fig:macrocoevolution:slimemould
  FIGNAME=6-2-3-fig-macrocoevol-slimemould
  echo $FIGNAME
  convert Figures/MacroCoEvol/example_slimemould_1_t0.png -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvol/example_slimemould_1_t0.jpg
  convert Figures/MacroCoEvol/example_slimemould_1_tf.png -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvol/example_slimemould_1_tf.jpg
  montage Figures/MacroCoEvol/example_slimemould_1_t0.jpg Figures/MacroCoEvol/example_slimemould_1_tf.jpg -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 $FIGDIR/"$FIGNAME".jpg
  rm Figures/MacroCoEvol/example_slimemould_1_t0.jpg Figures/MacroCoEvol/example_slimemould_1_tf.jpg



fi


###############
## Chapitre 7

if [ "$TARGET" == "--7" ] || [ "$TARGET" == "--all" ]
then

  ###############
  ## 7.1 : Network Heuristics

  # fig:networkgrowth:bioexample
  FIGNAME=7-1-1-fig-networkgrowth-bioexample
  echo $FIGNAME
  montage Figures/NetworkGrowth/example-bio-process-1.png Figures/NetworkGrowth/example-bio-process-1-tick80.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 -border 2 -bordercolor Black $FIGDIR/"$FIGNAME"_tmp.png
  convert $FIGDIR/"$FIGNAME"_tmp.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME"_tmp.png

  # fig:networkgrowth:examples
  FIGNAME=7-1-2-fig-networkgrowth-examples
  echo $FIGNAME
  montage Figures/NetworkGrowth/example_nw-connection.png Figures/NetworkGrowth/example_nw-random.png Figures/NetworkGrowth/example_nw-rndbrkdwn.png Figures/NetworkGrowth/example_nw-gravity.png Figures/NetworkGrowth/example_nw-cost.png Figures/NetworkGrowth/example_nw-bio.png -tile 3x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -border 2 -bordercolor Black $FIGDIR/"$FIGNAME"_tmp.png
  convert $FIGDIR/"$FIGNAME"_tmp.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME"_tmp.png

  # fig:networkgrowth:feasiblespace
  FIGNAME=7-1-2-fig-networkgrowth-feasiblespace
  echo $FIGNAME
  convert Figures/NetworkGrowth/feasible_space_pca.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:networkgrowth:realdistance
  FIGNAME=7-1-2-fig-networkgrowth-realdistance
  echo $FIGNAME
  montage Figures/NetworkGrowth/feasible_space_withreal_pca.png Figures/NetworkGrowth/distance_real.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 -resize "$((WIDTH / 2))"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME"_tmp.jpg
  convert Figures/NetworkGrowth/distance_real_bymorph.png -resize "$WIDTH"x -quality $JPGQUALITY Figures/NetworkGrowth/distance_real_bymorph.jpg
  montage $FIGDIR/"$FIGNAME"_tmp.jpg Figures/NetworkGrowth/distance_real_bymorph.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME"_tmp.jpg Figures/NetworkGrowth/distance_real_bymorph.jpg

  ###############
  ## 7.2 : Meso Coevol

  # fig:mesocoevolmodel:workflow
  # ok light pdf

  # fig:mesocoevolmodel:calibration
  FIGNAME=7-2-2-fig-mesocoevolmodel-calibration
  echo $FIGNAME
  montage Figures/MesoCoEvol/pca_allobjs.png Figures/MesoCoEvol/corrs-distrib_rhoasize4.png Figures/MesoCoEvol/pca_morpho_byheuristic.png Figures/MesoCoEvol/pca_network_byheuristic.png -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize "$((WIDTH / 2))"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:mesocoevolmodel:causality
  FIGNAME=7-2-2-fig-mesocoevolmodel-causality
  echo $FIGNAME
  montage Figures/MesoCoEvol/centertrajs.png Figures/MesoCoEvol/cluster-params.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 -resize "$((WIDTH / 2))"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg



fi



###############
## Chapitre 8

if [ "$TARGET" == "--8" ] || [ "$TARGET" == "--all" ]
then


  ###############
  ## 8.1 : Transportation Equilibrium

  # fig:transportationequilibrium:fig-1
  FIGNAME=8-1-2-fig-transportationequilibrium-fig-1
  echo $FIGNAME
  convert Figures/TransportationEquilibrium/gr1.png -resize $WIDTH -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:transportationequilibrium:fig-2
  FIGNAME=8-1-2-fig-transportationequilibrium-fig-2
  echo $FIGNAME
  montage Figures/TransportationEquilibrium/gr21.png Figures/TransportationEquilibrium/gr22.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 $FIGDIR/"$FIGNAME"_tmp.png
  convert $FIGDIR/"$FIGNAME"_tmp.png -resize $WIDTH -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME"_tmp.png

  # fig:transportationequilibrium:fig-3
  FIGNAME=8-1-2-fig-transportationequilibrium-fig-3
  echo $FIGNAME
  montage Figures/TransportationEquilibrium/gr31.png Figures/TransportationEquilibrium/gr32.png -tile 1x2 -geometry +0+"$VERTICALPADDING" $FIGDIR/"$FIGNAME"_tmp.png
  convert $FIGDIR/"$FIGNAME"_tmp.png -resize $WIDTH -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME"_tmp.png

  # fig:transportationequilibrium:fig-4
  FIGNAME=8-1-2-fig-transportationequilibrium-fig-4
  echo $FIGNAME
  convert Figures/TransportationEquilibrium/gr4.png -resize $WIDTH -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:transportationequilibrium:fig-5
  FIGNAME=8-1-2-fig-transportationequilibrium-fig-5
  echo $FIGNAME
  convert Figures/TransportationEquilibrium/gr5.png -resize $WIDTH -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg




  ###############
  ## 8.2 : Energy Price


  # fig:energyprice:map_price
  FIGNAME=8-2-2-fig-energyprice-map_price
  echo $FIGNAME
  convert Figures/EnergyPrice/average_regular_map.png -resize $WIDTH -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:energyprice:moran
  FIGNAME=8-2-2-fig-energyprice-moran
  echo $FIGNAME
  montage Figures/EnergyPrice/moran_days.png Figures/EnergyPrice/moran_decay_weeks.png -tile 2x1 -geometry +0+"$VERTICALPADDING" $FIGDIR/"$FIGNAME"_tmp.png
  convert $FIGDIR/"$FIGNAME"_tmp.png -resize $WIDTH -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME"_tmp.png

  # fig:energyprice:gwr
  FIGNAME=8-2-2-fig-energyprice-gwr
  echo $FIGNAME
  montage Figures/EnergyPrice/gwr_allbest_betaincome.png Figures/EnergyPrice/gwr_allbest_betapercapjobs.png Figures/EnergyPrice/gwr_allbest_wage.png Figures/EnergyPrice/gwr_allbest_LocalR2.png -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" $FIGDIR/"$FIGNAME"_tmp.png
  convert $FIGDIR/"$FIGNAME"_tmp.png -resize $WIDTH -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME"_tmp.png






fi
