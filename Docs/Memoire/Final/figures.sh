
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

mkdir -p $FIGDIR


###############
## Chapitre 1

if [ "$TARGET" == "--1" ] || [ "$TARGET" == "--all" ]
then

  ###############
  ## 1.2 : Case studies

  #fig:casestudies:gpe
  FIGNAME=1-2-1-fig-casestudies-gpe
  echo $FIGNAME
  #convert Figures/CaseStudies/timeaccess_metropole.png -resize "$WIDTH"x -quality $JPGQUALITY Figures/CaseStudies/timeaccess_metropole.jpg
  #convert Figures/CaseStudies/timegain_metropole.png -resize "$WIDTH"x -quality $JPGQUALITY Figures/CaseStudies/timegain_metropole.jpg
  #montage Figures/CaseStudies/timeaccess_metropole.png Figures/CaseStudies/timegain_metropole.png -tile 1x2 -geometry +0+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  convert Figures/CaseStudies/accesspdiff_metropole.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:casestudies:projects
  FIGNAME=1-2-1-fig-casestudies-projects
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/GrandParisRealEstate/reseaux.pdf -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:casestudies:empiricalres
  FIGNAME=1-2-1-fig-casestudies-empiricalres
  echo $FIGNAME
  convert Figures/GrandParisRealEstate/laggedcorrs_times_allvars_fr.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:casestudies:prd
  FIGNAME=1-2-1-fig-casestudies-prd
  echo $FIGNAME
  montage Figures/CaseStudies/accessp_withbridge_prd.png Figures/CaseStudies/accesspdiff_prd.png -resize "$WIDTH"x -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg


  ###############
  ## 1.3 : Qualitative

  # fig:qualitative:hsr
  FIGNAME=1-3-1-fig-qualitative-hsr
  echo $FIGNAME
  montage Figures/Qualitative/tangjia.jpg Figures/Qualitative/zhuhai.jpg Figures/Qualitative/yangshuo.jpg Figures/Qualitative/chengdu.jpg -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:qualitative:schema
  FIGNAME=1-3-1-fig-qualitative-schema
  echo $FIGNAME
  cp Figures/Qualitative/tod_fr.pdf $FIGDIR/"$FIGNAME".pdf




fi


###############
## Chapitre 2

if [ "$TARGET" == "--2" ] || [ "$TARGET" == "--all" ]
then

  ###############
  ## 2.2 : Quant Epistemo

  # fig:quantepistemo:citnw
  FIGNAME=2-2-2-fig-quantepistemo-citnw
  echo $FIGNAME
  convert Figures/QuantEpistemo/rawcore_labs36.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

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
  montage Figures/StaticCorrelations/cluster_pca_k5_morpho.png Figures/StaticCorrelations/cluster_map_k5_morpho.png -resize "$WIDTH"x -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 -quality $JPGQUALITY $FIGDIR/"$FIGNAME"_tmp.jpg
  montage Figures/StaticCorrelations/indics_morpho_areasize100_offset50_factor0.5.png $FIGDIR/"$FIGNAME"_tmp.jpg -resize "$WIDTH"x -tile 1x2 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME"_tmp.jpg
  #convert Figures/Density/Fig1.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:staticcorrs:network
  FIGNAME=4-1-2-fig-staticcorrs-network
  echo $FIGNAME
  convert Figures/StaticCorrelations/indics_network_areasize100_offset50_factor0.5.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:staticcorrs:mapscorrs
  FIGNAME=4-1-3-fig-staticcorrs-mapscorrs
  echo $FIGNAME
  montage Figures/StaticCorrelations/FR_corr_meanBetweenness.slope_rhoasize12.png Figures/StaticCorrelations/FR_corr_PC1_rhoasize12.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:staticcorrs:corrsdistrib
  FIGNAME=4-1-3-fig-staticcorrs-corrsdistrib
  echo $FIGNAME
  montage Figures/StaticCorrelations/corrs-summary-meanabs_varyingdelta_bytype.png Figures/StaticCorrelations/normalized_CI_delta.png -resize "$WIDTH"x -tile 1x2 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  #convert -density $PDFRESOLUTION Figures/StaticCorrelations/corrs-summary-meanabs_varyingdelta_bytype.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/StaticCorrelations/corrs-summary-meanabs_varyingdelta_bytype.jpg
  #convert -density $PDFRESOLUTION Figures/StaticCorrelations/normalized_CI_delta.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/StaticCorrelations/normalized_CI_delta.jpg
  #rm Figures/StaticCorrelations/corrs-summary-meanabs_varyingdelta_bytype.jpg;rm Figures/StaticCorrelations/normalized_CI_delta.jpg
  #convert Figures/Final/fig-staticcorrs-corrsdistrib_tmp1.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/fig-staticcorrs-corrsdistrib_tmp2.jpg
  #montage Figures/StaticCorrelations/normalized_CI_delta.jpg Figures/StaticCorrelations/scatter_meanabs_colcross.jpg -resize "$WIDTH"x -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 $FIGDIR/fig-staticcorrs-corrsdistrib_tmp3.jpg
  #convert Figures/Final/fig-staticcorrs-corrsdistrib_tmp3.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/fig-staticcorrs-corrsdistrib_tmp4.jpg
  #rm Figures/Final/fig-staticcorrs-corrsdistrib_tmp1.jpg;rm Figures/Final/fig-staticcorrs-corrsdistrib_tmp2.jpg;rm Figures/Final/fig-staticcorrs-corrsdistrib_tmp3.jpg;rm Figures/Final/fig-staticcorrs-corrsdistrib_tmp4.jpg
  # montage Figures/StaticCorrelations/corrs-distrib_varyingdelta_bytype.jpg Figures/StaticCorrelations/corrs-summary-meanabs_varyingdelta_bytype.jpg -resize "$WIDTH"x -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 $FIGDIR/fig-staticcorrs-corrsdistrib_tmp1.jpg


  ###############
  ## 4.2 : Spatio-temp causalities

  # fig:causalityregimes:arma
  FIGNAME=4-2-2-fig-causalityregimes-arma
  echo $FIGNAME
  montage Figures/CausalityRegimes/coefsclust_nbootstrap10000_maxai0_1_lag2nclust9.png Figures/CausalityRegimes/centertrajs_nbootstrap10000_maxai0_1_lag2nclust9.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+0  -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # frame:causalityregimes:rbd
  FIGNAME=4-2-2-frame-causalityregimes-rdb
  echo $FIGNAME
  montage Figures/CausalityRegimes/ex_60_wdens0_wroad1_wcenter1_seed272727.png Figures/CausalityRegimes/ex_60_wdens1_wroad1_wcenter0_seed272727.png Figures/CausalityRegimes/ex_60_wdens1_wroad1_wcenter1_seed272727.png -tile 3x1 -geometry +"$HORIZONTALPADDING"+0  -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:causalityregimes:exrdb
  FIGNAME=4-2-2-fig-causalityregimes-exrdb
  echo $FIGNAME
  convert Figures/CausalityRegimes/synth_extreme.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  #convert -colorspace sRGB -density $PDFRESOLUTION Figures/CausalityRegimes/synth_extreme.pdf -background white -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  #convert Figures/Final/fig-causalityregimes-exrdb_tmp.png -resize "$WIDTH"x -quality $JPGQUALITY Figures/Final/fig-causalityregimes-exrdb_tmp.jpg
  #rm $FIGDIR/fig-causalityregimes-exrdb_tmp.png
  #montage Figures/Final/fig-causalityregimes-exrdb_tmp.jpg Figures/Final/laggedcorrs_facetextreme.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  #rm $FIGDIR/fig-causalityregimes-exrdb_tmp.jpg
  #rm $FIGDIR/laggedcorrs_facetextreme.jpg



  # fig:causalityregimes:clustering
  FIGNAME=4-2-2-fig-causalityregimes-clustering
  echo $FIGNAME
  convert Figures/CausalityRegimes/clusters-paramfacet_valuesFALSEtheta2_k6.png -resize "$WIDTH"x -quality $JPGQUALITY Figures/CausalityRegimes/clusters-paramfacet_valuesFALSEtheta2_k6.jpg
  convert Figures/CausalityRegimes/clusters-centertrajs-facetclust_valuesFALSEtheta2_k6.png -resize "$WIDTH"x -quality $JPGQUALITY Figures/CausalityRegimes/clusters-centertrajs-facetclust_valuesFALSEtheta2_k6.jpg
  montage Figures/CausalityRegimes/clusters-paramfacet_valuesFALSEtheta2_k6.jpg Figures/CausalityRegimes/clusters-centertrajs-facetclust_valuesFALSEtheta2_k6.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  #montage Figures/CausalityRegimes/clusters-PCA-features_valuesFALSEtheta2_k6.jpg Figures/CausalityRegimes/clusters-paramfacet_valuesFALSEtheta2_k6.jpg -tile 2x1 -geometry +0+"$HORIZONTALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/fig-causalityregimes-clustering_tmp2.jpg
  #convert $FIGDIR/fig-causalityregimes-clustering_tmp1.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/fig-causalityregimes-clustering_tmp3.jpg
  #convert $FIGDIR/fig-causalityregimes-clustering_tmp2.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/fig-causalityregimes-clustering_tmp4.jpg
  #montage $FIGDIR/fig-causalityregimes-clustering_tmp3.jpg $FIGDIR/fig-causalityregimes-clustering_tmp4.jpg Figures/CausalityRegimes/clusters-centertrajs-facetclust_valuesFALSEtheta2_k6.jpg -tile 1x3 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/CausalityRegimes/clusters-paramfacet_valuesFALSEtheta2_k6.jpg;rm Figures/CausalityRegimes/clusters-centertrajs-facetclust_valuesFALSEtheta2_k6.jpg
  #rm $FIGDIR/fig-causalityregimes-clustering_tmp2.jpg;rm $FIGDIR/fig-causalityregimes-clustering_tmp3.jpg;rm $FIGDIR/fig-causalityregimes-clustering_tmp4.jpg


  # fig:causalityregimes:network
  FIGNAME=4-2-3-fig-causalityregimes-network
  echo $FIGNAME
  montage Figures/CausalityRegimes/nw_efficiency.png Figures/CausalityRegimes/nw_meanCentralities.png Figures/CausalityRegimes/nw_hierarchies.png Figures/CausalityRegimes/nw_nwSize.png -resize "$WIDTH"x -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  #convert -density $PDFRESOLUTION Figures/CausalityRegimes/nw_nwSize.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/CausalityRegimes/nw_nwSize.jpg
  #convert -density $PDFRESOLUTION Figures/CausalityRegimes/nw_meanCentralities.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/CausalityRegimes/nw_meanCentralities.jpg
  #convert -density $PDFRESOLUTION Figures/CausalityRegimes/nw_hierarchies.pdf -resize "$((WIDTH + 100))"x -quality $JPGQUALITY Figures/CausalityRegimes/nw_hierarchies.jpg
  #convert -density $PDFRESOLUTION Figures/CausalityRegimes/nw_efficiency.pdf -resize "$((WIDTH - 100))"x -quality $JPGQUALITY Figures/CausalityRegimes/nw_efficiency.jpg
  #montage Figures/CausalityRegimes/nw_nwSize.jpg Figures/CausalityRegimes/nw_meanCentralities.jpg Figures/CausalityRegimes/nw_hierarchies.jpg Figures/CausalityRegimes/nw_efficiency.jpg -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME"_tmp.jpg
  #convert $FIGDIR/"$FIGNAME"_tmp.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  #rm Figures/CausalityRegimes/nw_nwSize.jpg Figures/CausalityRegimes/nw_meanCentralities.jpg Figures/CausalityRegimes/nw_hierarchies.jpg Figures/CausalityRegimes/nw_efficiency.jpg $FIGDIR/"$FIGNAME"_tmp.jpg

  # fig:causalityregimes:sudafcorrs
  FIGNAME=4-2-3-fig-causalityregimes-sudafcorrs
  echo $FIGNAME
  convert Figures/CausalityRegimes/laggedCorrs_time_Tw3.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg



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
  montage Figures/InteractionGibrat/logmse-feedbackDecay_ZOOM.png Figures/InteractionGibrat/mselog-feedbackDecay_ZOOM.png  -resize "$WIDTH"x -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  #convert Figures/InteractionGibrat/Fig3.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:interactiongibrat:gravity-pareto
  FIGNAME=4-3-2-fig-interactiongibrat-gravity-pareto
  echo $FIGNAME
  convert Figures/InteractionGibrat/Fig4.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:interactiongibrat:gravity-params
  FIGNAME=4-3-2-fig-interactiongibrat-gravity-params
  echo $FIGNAME
  montage Figures/InteractionGibrat/growthRate_filt1.png Figures/InteractionGibrat/gravityWeight_filt1.png Figures/InteractionGibrat/gravityDecay_filt1.png Figures/InteractionGibrat/gravityGamma_filt1.png  -resize "$WIDTH"x -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  #convert Figures/InteractionGibrat/Fig5.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:interactiongibrat:feedback
  FIGNAME=4-3-2-fig-interactiongibrat-feedback
  echo $FIGNAME
  montage Figures/InteractionGibrat/growthRate_filt0.png Figures/InteractionGibrat/gravityWeight_relativegrowthRate.png Figures/InteractionGibrat/feedbackDecay_filt0.png Figures/InteractionGibrat/feedbackGamma_filt0.png  -resize "$WIDTH"x -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  #convert Figures/InteractionGibrat/Fig6.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg




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
convert -density $PDFRESOLUTION Figures/CorrelatedSyntheticData/hist_crossCorMat_breaks30.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/CorrelatedSyntheticData/hist_crossCorMat_breaks30.jpg
convert Figures/CorrelatedSyntheticData/pca_realDistCol_meanAbsCorSize_withSpecificPoints.png -resize "$WIDTH"x -quality $JPGQUALITY Figures/CorrelatedSyntheticData/pca_realDistCol_meanAbsCorSize_withSpecificPoints.jpg
montage Figures/CorrelatedSyntheticData/hist_crossCorMat_breaks30.jpg Figures/CorrelatedSyntheticData/pca_realDistCol_meanAbsCorSize_withSpecificPoints.jpg -tile 1x2 -geometry +"$VERTICALPADDING"+0 -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
#montage $FIGDIR/"$FIGNAME"_tmp1.jpg $FIGDIR/"$FIGNAME"_tmp2.jpg -tile 1x2 -geometry +"$VERTICALPADDING"+0 -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
rm Figures/CorrelatedSyntheticData/pca_realDistCol_meanAbsCorSize_withSpecificPoints.jpg Figures/CorrelatedSyntheticData/hist_crossCorMat_breaks30.jpg


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
  convert -density $PDFRESOLUTION Figures/MacroCoEvolExplo/closenessEntropies_networkGamma2.5_networkSpeed110_gravityDecay0.016_networkThreshold11.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvolExplo/fig1.jpg
  convert -density $PDFRESOLUTION Figures/MacroCoEvolExplo/rankCorrPop_networkSpeed110_networkThreshold11_networkGamma2.5.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvolExplo/fig2.jpg
  montage Figures/MacroCoEvolExplo/fig1.jpg Figures/MacroCoEvolExplo/fig2.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/MacroCoEvolExplo/fig1.jpg Figures/MacroCoEvolExplo/fig2.jpg

  # fig:macrocoevolexplo:correlations
  FIGNAME=6-1-3-fig-macrocoevolexplo-correlations
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/MacroCoEvolExplo/distcorrs_networkGamma2.5_networkSpeed110_gravityDecay0.016_networkThreshold11.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvolExplo/fig3.jpg
  convert -density $PDFRESOLUTION Figures/MacroCoEvolExplo/laggedcorrs_networkGamma2.5_networkSpeed10_gravityDecay0.016_networkThreshold21.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvolExplo/fig4.jpg
  montage Figures/MacroCoEvolExplo/fig3.jpg Figures/MacroCoEvolExplo/fig4.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/MacroCoEvolExplo/fig3.jpg Figures/MacroCoEvolExplo/fig4.jpg


  ###############
  ## 6.2 : Macro-coevol

  # fig:macrocoevol:model
  # ok, very light pdf


  ##montage Figures/MacroCoEvol/closenessSummaries_mean_gravityWeight0_001.jpg Figures/MacroCoEvol/populationEntropies_gravityWeight0_001.jpg Figures/MacroCoEvol/complexityAccessibility_synthrankSize1_nwGmax0_05.jpg Figures/MacroCoEvol/rankCorrAccessibility_synthrankSize1_nwGmax0_05.jpg -tile 2x2 -geometry +"$VERTICALPADDING"+"$HORIZONTALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg


  # fig:macrocoevol:behavior-time
  FIGNAME=6-2-2-fig-macrocoevol-behavior-time
  echo $FIGNAME
  montage Figures/MacroCoEvol/closenessSummaries_mean_synthRankSize1_gravityWeight0_001_gravityDecay10.png Figures/MacroCoEvol/populationEntropies_synthRankSize1_gravityWeight0_001_gravityGamma0_5.png -tile 1x2 -geometry +0+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:macrocoevol:behavior-aggreg
  FIGNAME=6-2-2-fig-macrocoevol-behavior-aggreg
  echo $FIGNAME
  montage Figures/MacroCoEvol/complexityAccessibility_synthrankSize1_nwGmax0_05_gravityWeight0_001.png Figures/MacroCoEvol/rankCorrAccessibility_synthrankSize1_nwGmax0_05_gravityWeight0_001.png -tile 1x2 -geometry +0+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg


  # fig:macrocoevol:correlations
  FIGNAME=6-2-2-fig-macrocoevol-correlations
  echo $FIGNAME
  convert Figures/MacroCoEvol/laggedregimes_nwGmax0_05.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg


  # fig:macrocoevol:empirical
  FIGNAME=6-2-3-fig-macrocoevol-empirical
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/significantcorrs_Tw.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvol/significantcorrs_Tw.jpg
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/significantcorrs_d0.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvol/significantcorrs_d0.jpg
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/laggedCorrs_time_Tw4.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/MacroCoEvol/laggedCorrs_time_Tw4.jpg
  montage Figures/MacroCoEvol/significantcorrs_Tw.jpg Figures/MacroCoEvol/significantcorrs_d0.jpg -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 -quality $JPGQUALITY $FIGDIR/"$FIGNAME"_tmp.jpg
  montage $FIGDIR/"$FIGNAME"_tmp.jpg Figures/MacroCoEvol/laggedCorrs_time_Tw4.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/MacroCoEvol/significantcorrs_Tw.jpg Figures/MacroCoEvol/significantcorrs_d0.jpg Figures/MacroCoEvol/laggedCorrs_time_Tw4.jpg $FIGDIR/"$FIGNAME"_tmp.jpg


  # fig:macrocoevol:pareto
  FIGNAME=6-2-3-fig-macrocoevol-pareto
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/pareto_nwGmax_filtTRUE.pdf -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg


  # fig:macrocoevol:parameters
  FIGNAME=6-2-3-fig-macrocoevol-parameters
  echo $FIGNAME
  montage Figures/MacroCoEvol/param_growthRate_filt1.png Figures/MacroCoEvol/param_gravityWeight_filt1.png Figures/MacroCoEvol/param_gravityDecay_filt1.png Figures/MacroCoEvol/param_gravityGamma_filt1.png Figures/MacroCoEvol/param_nwThreshold_filt1.png Figures/MacroCoEvol/param_nwGmax_filt1.png -tile 3x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" $FIGDIR/"$FIGNAME"_tmp.png
  # Figures/MacroCoEvol/param_nwExponent_filt1.png
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
  montage Figures/NetworkGrowth/example_comp_nwSize200_connex.png Figures/NetworkGrowth/example_comp_nwSize200_random.png Figures/NetworkGrowth/example_comp_nwSize200_rndbrkdwn.png Figures/NetworkGrowth/example_comp_nwSize200_detbrkdwn.png Figures/NetworkGrowth/example_comp_nwSize200_cost.png Figures/NetworkGrowth/example_comp_nwSize200_bio.png -tile 3x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -border 2 -bordercolor Black $FIGDIR/"$FIGNAME"_tmp.png
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
  montage Figures/MesoCoEvol/pca_morpho_byheuristic.png Figures/MesoCoEvol/pca_network_byheuristic.png Figures/MesoCoEvol/pca_allobjs.png Figures/MesoCoEvol/distance-corrs-distrib_rhoasize4.png -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize "$((WIDTH / 2))"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  #montage Figures/MesoCoEvol/pca_morpho_byheuristic.png Figures/MesoCoEvol/pca_network_byheuristic.png Figures/MesoCoEvol/pca_allobjs.png Figures/MesoCoEvol/distance-all-distrib_rhoasize4.png Figures/MesoCoEvol/distance-indics-distrib_rhoasize4.png Figures/MesoCoEvol/distance-corrs-distrib_rhoasize4.png -tile 2x3 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize "$((WIDTH / 2))"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg


  # fig:mesocoevolmodel:causality
  FIGNAME=7-2-2-fig-mesocoevolmodel-causality
  echo $FIGNAME
  convert Figures/MesoCoEvol/centertrajs.png -resize "$((3 * WIDTH / 5))"x -quality $JPGQUALITY Figures/MesoCoEvol/centertrajs.jpg
  convert Figures/MesoCoEvol/cluster-params-gridRoadPop.png -resize "$((2 * WIDTH / 5))"x -quality $JPGQUALITY Figures/MesoCoEvol/cluster-params.jpg
  montage Figures/MesoCoEvol/centertrajs.jpg Figures/MesoCoEvol/cluster-params.jpg -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 $FIGDIR/"$FIGNAME".jpg
  rm Figures/MesoCoEvol/centertrajs.jpg Figures/MesoCoEvol/cluster-params.jpg


  ###############
  ## 7.3 : Lutecia

  # fig:lutecia:governance
  FIGNAME=7-3-3-fig-lutecia-governance
  echo $FIGNAME
  montage Figures/Lutecia/ex_setup.png Figures/Lutecia/ex_reg_infra50_explo200_seed1.png Figures/Lutecia/ex_maxcollabcost_infra45_explo200_seed3.png Figures/Lutecia/ex_mincollabcost_infra50_explo200_seed1.png -resize "$WIDTH"x -quality $JPGQUALITY -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" $FIGDIR/"$FIGNAME".jpg


  # fig:lutecia:ex-prd
  FIGNAME=7-3-3-fig-lutecia-ex-prd
  echo $FIGNAME
  montage Figures/Lutecia/exrun_2_tick0.png Figures/Lutecia/exrun_2_tick6.png -resize "$WIDTH"x -quality $JPGQUALITY -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 $FIGDIR/"$FIGNAME".jpg


  # fig:lutecia:calib
  FIGNAME=7-3-3-fig-lutecia-calib
  echo $FIGNAME
  montage Figures/Lutecia/regional-distance_colorgametype.png Figures/Lutecia/collab-distance_colorregional.png Figures/Lutecia/distanceviolin_gametype.png Figures/Lutecia/distanceviolin_gametype_real.png -resize "$WIDTH"x -quality $JPGQUALITY -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" $FIGDIR/"$FIGNAME".jpg






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
  montage Figures/EnergyPrice/moran_days.png Figures/EnergyPrice/moran_decay_weeks.png -tile 1x2 -geometry +0+"$VERTICALPADDING" -resize $WIDTH -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:energyprice:gwr
  FIGNAME=8-2-2-fig-energyprice-gwr
  echo $FIGNAME
  montage Figures/EnergyPrice/gwr_allbest_betaincome.png Figures/EnergyPrice/gwr_allbest_betapercapjobs.png Figures/EnergyPrice/gwr_allbest_wage.png Figures/EnergyPrice/gwr_allbest_LocalR2.png -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" $FIGDIR/"$FIGNAME"_tmp.png
  convert $FIGDIR/"$FIGNAME"_tmp.png -resize $WIDTH -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME"_tmp.png






fi




###############
## Conclusion

if [ "$TARGET" == "--CL" ] || [ "$TARGET" == "--all" ]
then

  # artwork
  FIGNAME=CL-artwork
  echo $FIGNAME
  convert Figures/Art/Capture\ d’écran\ 2016-08-08\ à\ 11.46.55.png -resize $WIDTH -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg


fi


###############
## Appendix A

if [ "$TARGET" == "--A" ] || [ "$TARGET" == "--all" ]
then


  #############
  ## casestudies

  # fig:app:casestudies:nanfang
  FIGNAME=A-casestudies-nanfang
  echo $FIGNAME
  convert Figures/CaseStudies/nanfang.png -resize $WIDTH -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:casestudies:prd
  FIGNAME=A-casestudies-prd
  echo $FIGNAME
  convert Figures/CaseStudies/prd.png -resize $WIDTH -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:casestudies:zhuhai
  FIGNAME=A-casestudies-zhuhai
  echo $FIGNAME
  convert Figures/CaseStudies/zhuhai.png -resize $WIDTH -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg


  #############
  ## quantepistemo

  # fig:quantepistemo:sensitivity-algosr
  FIGNAME=A-quantepistemo-sensitivity-algosr
  echo $FIGNAME
  convert Figures/QuantEpistemo/explo.png -resize "$WIDTH"x -quality $JPGQUALITY Figures/QuantEpistemo/explo.jpg
  convert -density $PDFRESOLUTION Figures/QuantEpistemo/lexicalConsistence_MeanSd.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/QuantEpistemo/lexicalConsistence_MeanSd.jpg
  montage Figures/QuantEpistemo/explo.jpg Figures/QuantEpistemo/lexicalConsistence_MeanSd.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" $FIGDIR/"$FIGNAME".jpg
  rm Figures/QuantEpistemo/explo.jpg Figures/QuantEpistemo/lexicalConsistence_MeanSd.jpg

  # fig:app:quantepistemo:sensitivity
  FIGNAME=A-quantepistemo-sensitivity
  echo $FIGNAME
  montage Figures/Quantepistemo/pareto-com-vertices.png Figures/Quantepistemo/pareto-modularity-vertices.png -resize "$((WIDTH / 2))"x -quality $JPGQUALITY -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 $FIGDIR/"$FIGNAME"_tmp.jpg
  convert Figures/Quantepistemo/sensitivity_freqmin0_normalized.png -resize "$WIDTH"x -quality $JPGQUALITY Figures/Quantepistemo/sensitivity_freqmin0_normalized.jpg
  montage $FIGDIR/"$FIGNAME"_tmp.jpg Figures/Quantepistemo/sensitivity_freqmin0_normalized.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME"_tmp.jpg Figures/Quantepistemo/sensitivity_freqmin0_normalized.jpg

  # fig:app:quantepistemo:semanticnw
  FIGNAME=A-quantepistemo-semanticnw
  echo $FIGNAME
  convert Figures/Quantepistemo/semantic.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:quantepistemo:regressions
  FIGNAME=A-quantepistemo-regressions
  echo $FIGNAME
  montage Figures/QuantEpistemo/lm_adjr2-aicc_INTERDISC.pdf Figures/QuantEpistemo/lm_adjr2-aicc_SPATSCALE.pdf Figures/QuantEpistemo/lm_adjr2-aicc_TEMPSCALE.pdf Figures/QuantEpistemo/lm_adjr2-aicc_YEAR.pdf -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" $FIGDIR/"$FIGNAME"_tmp.pdf
  convert -density $PDFRESOLUTION $FIGDIR/"$FIGNAME"_tmp.pdf -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME"_tmp.pdf

  #############
  ## staticcorrelations

  # fig:app:staticcorrelations:morphocn
  FIGNAME=A-staticcorrelations-morphocn
  echo $FIGNAME
  convert Figures/StaticCorrelations/CN_indics_morpho.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:staticcorrelations:networkcn
  FIGNAME=A-staticcorrelations-networkcn
  echo $FIGNAME
  convert Figures/StaticCorrelations/CN_indics_network_selected.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg


  # fig:app:staticcorrelations:overallcorrs
  FIGNAME=A-staticcorrelations-overallcorrs
  echo $FIGNAME
  convert Figures/StaticCorrelations/corrmat_deltainfty_corrplot.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg


  # fig:app:staticcorrelations:europe-correlations
  FIGNAME=A-staticcorrelations-europe-correlations
  echo $FIGNAME
  montage Figures/StaticCorrelations/corr_alphaCloseness.moran_rhoasize12.png Figures/StaticCorrelations/corr_slope.moran_rhoasize12.png Figures/StaticCorrelations/corr_meanBetweenness.slope_rhoasize12.png Figures/StaticCorrelations/corr_alphaCloseness.alphaBetweenness_rhoasize12.png Figures/StaticCorrelations/corr_vcount.meanPathLength_rhoasize12.png Figures/StaticCorrelations/corr_slope.rsquaredslope_rhoasize12.png -resize "$WIDTH"x -tile 2x3 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg


  # fig:app:staticcorrelations:corr-distribs
  FIGNAME=A-staticcorrelations-corr-distribs
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/StaticCorrelations/corrs-distrib_varyingdelta_bytype.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/StaticCorrelations/corrs-distrib_varyingdelta_bytype.jpg
  convert Figures/StaticCorrelations/scatter_meanabs_colcross.png -resize "$WIDTH"x -quality $JPGQUALITY Figures/StaticCorrelations/scatter_meanabs_colcross.jpg
  montage Figures/StaticCorrelations/corrs-distrib_varyingdelta_bytype.jpg Figures/StaticCorrelations/scatter_meanabs_colcross.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/StaticCorrelations/corrs-distrib_varyingdelta_bytype.jpg;rm Figures/StaticCorrelations/scatter_meanabs_colcross.jpg


  # fig:app:staticcorrelations:sensitivity-maps-morpho
  FIGNAME=A-staticcorrelations-sensitivity-maps-morpho
  echo $FIGNAME
  montage Figures/StaticCorrelations/indics_morpho_areasize60_offset30_factor0.5.png Figures/StaticCorrelations/indics_morpho_areasize200_offset100_factor0.5.png  -tile 1x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" $FIGDIR/"$FIGNAME"_tmp.png
  convert $FIGDIR/"$FIGNAME"_tmp.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME"_tmp.png

  # fig:app:staticcorrelations:sensitivity-maps-network
  FIGNAME=A-staticcorrelations-sensitivity-maps-network
  echo $FIGNAME
  montage Figures/StaticCorrelations/indics_network_areasize60_offset30_factor0.5.png Figures/StaticCorrelations/indics_network_areasize200_offset100_factor0.5.png  -tile 1x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" $FIGDIR/"$FIGNAME"_tmp.png
  convert $FIGDIR/"$FIGNAME"_tmp.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME"_tmp.png


  # fig:app:staticcorrelations:sensitivity-corrs
  FIGNAME=A-staticcorrelations-sensitivity-corrs
  echo $FIGNAME
  montage Figures/StaticCorrelations/sensit_morpho_low60_high100.png Figures/StaticCorrelations/sensit_network_low60_high100.png Figures/StaticCorrelations/sensit_morpho_low60_high200.png Figures/StaticCorrelations/sensit_network_low60_high200.png Figures/StaticCorrelations/sensit_morpho_low100_high200.png Figures/StaticCorrelations/sensit_network_low100_high200.png Figures/StaticCorrelations/sensit_morpho_crossed.png Figures/StaticCorrelations/sensit_network_crossed.png -tile 2x4 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" $FIGDIR/"$FIGNAME"_tmp.png
  convert $FIGDIR/"$FIGNAME"_tmp.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME"_tmp.png



  #############
  ## spatio-temp causalities


  #fig:app:causalityregimes:clustering
  FIGNAME=A-causalityregimes-clustering
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/CausalityRegimes/ccoef-knum_valuesFALSE_theta05-3.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/CausalityRegimes/ccoef-knum_valuesFALSE_theta05-3.jpg
  convert -density $PDFRESOLUTION Figures/CausalityRegimes/dccoef-knum_valuesFALSEtheta05-3.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/CausalityRegimes/dccoef-knum_valuesFALSEtheta05-3.jpg
  montage Figures/CausalityRegimes/ccoef-knum_valuesFALSE_theta05-3.jpg Figures/CausalityRegimes/dccoef-knum_valuesFALSEtheta05-3.jpg -tile 2x1 -geometry +0+"$HORIZONTALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/fig-causalityregimes-clustering_tmp1.jpg
  convert Figures/CausalityRegimes/clusters-PCA-features_valuesFALSEtheta2_k6.png -quality $JPGQUALITY Figures/CausalityRegimes/clusters-PCA-features_valuesFALSEtheta2_k6.jpg
  montage $FIGDIR/fig-causalityregimes-clustering_tmp1.jpg Figures/CausalityRegimes/clusters-PCA-features_valuesFALSEtheta2_k6.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/CausalityRegimes/ccoef-knum_valuesFALSE_theta05-3.jpg;rm Figures/CausalityRegimes/dccoef-knum_valuesFALSEtheta05-3.jpg
  rm $FIGDIR/fig-causalityregimes-clustering_tmp1.jpg;  rm Figures/CausalityRegimes/clusters-PCA-features_valuesFALSEtheta2_k6.jpg


  # fig:app:causalityregimes:sudafcorrs
  FIGNAME=A-causalityregimes-sudafcorrs
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/CausalityRegimes/meanabscorrs.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/CausalityRegimes/meanabscorrs.jpg
  convert -density $PDFRESOLUTION Figures/CausalityRegimes/significantcorrs.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/CausalityRegimes/significantcorrs.jpg
  convert -density $PDFRESOLUTION Figures/CausalityRegimes/laggedCorrs_Tw3.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/CausalityRegimes/laggedCorrs_Tw3.jpg
  montage Figures/CausalityRegimes/meanabscorrs.jpg Figures/CausalityRegimes/significantcorrs.jpg -tile 2x1 -geometry +0+"$HORIZONTALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME"_tmp.jpg
  montage $FIGDIR/"$FIGNAME"_tmp.jpg Figures/CausalityRegimes/laggedCorrs_Tw3.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME"_tmp.jpg Figures/CausalityRegimes/meanabscorrs.jpg Figures/CausalityRegimes/significantcorrs.jpg Figures/CausalityRegimes/laggedCorrs_Tw3.jpg







  ##############
  ## Density

  # fig:app:density:histograms
  FIGNAME=A-density-histograms
  echo $FIGNAME
  montage Figures/Density/hist_moran.png Figures/Density/hist_slope.png -tile 1x2 -geometry +"$VERTICALPADDING"+0 -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:density:moran
  FIGNAME=A-density-moran
  echo $FIGNAME
  montage Figures/Density/moran_alpha.jpg Figures/Density/moran_beta.jpg -tile 1x2 -geometry +"$VERTICALPADDING"+0 -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:density:slope
  FIGNAME=A-density-slope
  echo $FIGNAME
  montage Figures/Density/slope_alpha.jpg Figures/Density/slope_beta.jpg -tile 1x2 -geometry +"$VERTICALPADDING"+0 -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:density:distance
  FIGNAME=A-density-distance
  echo $FIGNAME
  montage Figures/Density/distance_alpha.jpg Figures/Density/distance_beta.jpg -tile 1x2 -geometry +"$VERTICALPADDING"+0 -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:density:entropy
  FIGNAME=A-density-entropy
  echo $FIGNAME
  montage Figures/Density/entropy_alpha.jpg Figures/Density/entropy_beta.jpg -tile 1x2 -geometry +"$VERTICALPADDING"+0 -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:density:densityscatter
  FIGNAME=A-density-densityscatter
  echo $FIGNAME
  convert Figures/Density/scatter.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:density:stationary
  FIGNAME=A-density-stationary
  echo $FIGNAME
  convert Figures/Density/stationary.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:density:pmax
  FIGNAME=A-density-pmax
  echo $FIGNAME
  montage Figures/Density/pmax_alpha.png Figures/Density/pmax_logbeta.png -tile 2x1 -geometry +0+"$HORIZONTALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg


  #############
  ## Synthetic Data

  #fig:app:correlatedsyntheticdata:correlations
  FIGNAME=A-correlatedsyntheticdata-correlations
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/CorrelatedSyntheticData/pca_meanAbsCor_errorBars.pdf -resize "$((2 * WIDTH / 3))"x -quality $JPGQUALITY Figures/CorrelatedSyntheticData/pca_meanAbsCor_errorBars.jpg
  #convert Figures/CorrelatedSyntheticData/heatmaps.png -resize "$((WIDTH / 3))"x -quality $JPGQUALITY Figures/CorrelatedSyntheticData/heatmaps.jpg
  montage Figures/CorrelatedSyntheticData/heatmap_maxabscorr.png Figures/CorrelatedSyntheticData/heatmap_amplitude.png -tile 1x2 -geometry +0+"$VERTICALPADDING" -resize "$((WIDTH / 3))"x -quality $JPGQUALITY Figures/CorrelatedSyntheticData/heatmaps.jpg
  montage Figures/CorrelatedSyntheticData/pca_meanAbsCor_errorBars.jpg Figures/CorrelatedSyntheticData/heatmaps.jpg -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/CorrelatedSyntheticData/heatmaps.jpg Figures/CorrelatedSyntheticData/pca_meanAbsCor_errorBars.jpg



  #############
  ## MacroCoEvol


  # fig:app:macrocoevol:behavior-time
  FIGNAME=A-macrocoevol-behavior-time
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/closenessSummaries_meansynthRankSize1_gravityWeight0_001.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvol/closenessSummaries_mean_gravityWeight0_001.jpg
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/populationEntropiessynthRankSize1_gravityWeight0_001.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvol/populationEntropies_gravityWeight0_001.jpg
  montage Figures/MacroCoEvol/closenessSummaries_mean_gravityWeight0_001.jpg Figures/MacroCoEvol/populationEntropies_gravityWeight0_001.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/MacroCoEvol/closenessSummaries_mean_gravityWeight0_001.jpg Figures/MacroCoEvol/populationEntropies_gravityWeight0_001.jpg


  # fig:app:macrocoevol:behavior-aggreg
  FIGNAME=A-macrocoevol-behavior-aggreg
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/complexityAccessibility_synthrankSize1_nwGmax0_05.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvol/complexityAccessibility_synthrankSize1_nwGmax0_05.jpg
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/rankCorrAccessibility_synthrankSize1_nwGmax0_05.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/MacroCoEvol/rankCorrAccessibility_synthrankSize1_nwGmax0_05.jpg
  montage Figures/MacroCoEvol/complexityAccessibility_synthrankSize1_nwGmax0_05.jpg Figures/MacroCoEvol/rankCorrAccessibility_synthrankSize1_nwGmax0_05.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/MacroCoEvol/complexityAccessibility_synthrankSize1_nwGmax0_05.jpg Figures/MacroCoEvol/rankCorrAccessibility_synthrankSize1_nwGmax0_05.jpg

  FIGNAME=A-macrocoevol-distcorrs
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/distcorrs_gravityWeight5e-04_nwThreshold4_5.pdf -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  FIGNAME=A-macrocoevol-laggedcorrs
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/laggedcorrs_gravityWeight5e-04_nwThreshold4_5.pdf -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg


  # fig:app:macrocoevol:pareto
  FIGNAME=A-macrocoevol-pareto
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/MacroCoEvol/pareto_gravityDecay_filtTRUE.pdf -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  # pareto_nwThreshold_filtTRUE.pdf


  #############
  ## networkgrowth

  # fig:app:networkgrowth:feasiblespace_bymorph
  FIGNAME=A-networkgrowth-feasiblespace_bymorph
  echo $FIGNAME
  montage Figures/NetworkGrowth/feasible_space_pca_bymorph.png Figures/NetworkGrowth/feasible_space_withreal_pca_bymorph.png -tile 1x2 -geometry +0+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg


  ############
  ## Mesocoevol

  # fig:app:mesocoevolmodel:paretodists
  FIGNAME=A-mesocoevolmodel-paretodists
  echo $FIGNAME
  montage Figures/MesoCoEvol/dists_pareto_i1.png Figures/MesoCoEvol/dists_pareto_i10.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg


  #############
  ## Lutecia

  # fig:app:lutecia:morphotrajs
  FIGNAME=A-lutecia-morphotrajs
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/Lutecia/morphoActiveTrajsvaryinglambda_betaDC1_euclpace6.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/Lutecia/morphoActiveTrajsvaryinglambda_betaDC1_euclpace6.jpg
  convert -density $PDFRESOLUTION Figures/Lutecia/morphoActiveTrajsvaryinglambda_betaDC2_euclpace6.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/Lutecia/morphoActiveTrajsvaryinglambda_betaDC2_euclpace6.jpg
  montage Figures/Lutecia/morphoActiveTrajsvaryinglambda_betaDC1_euclpace6.jpg Figures/Lutecia/morphoActiveTrajsvaryinglambda_betaDC2_euclpace6.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm Figures/Lutecia/morphoActiveTrajsvaryinglambda_betaDC1_euclpace6.jpg Figures/Lutecia/morphoActiveTrajsvaryinglambda_betaDC2_euclpace6.jpg

  # fig:app:lutecia:morphosens
  FIGNAME=A-lutecia-morphosens
  echo $FIGNAME
  convert Figures/Lutecia/PC1_synth_nonw_euclpace6.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:lutecia:ludiff
  FIGNAME=A-lutecia-ludiff
  echo $FIGNAME
  convert Figures/Lutecia/rdiffact_synth_nonw_euclpace6.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg



  # fig:app:lutecia:realsetup
  FIGNAME=A-lutecia-realsetup
  echo $FIGNAME
  montage Figures/Lutecia/ex_real_filesetup.png Figures/Lutecia/realnonw_nolu.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg



fi



###############
## Appendix B

if [ "$TARGET" == "--B" ] || [ "$TARGET" == "--all" ]
then


  ###############
  ## Robustness Discrepancy

  # fig:robustness:segreg
  FIGNAME=B-robustness-segreg
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/RobustnessDiscrepancy/grandParis_income_moran.pdf -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:robustness:sensitivity
  FIGNAME=B-robustness-sensitivity
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/RobustnessDiscrepancy/alldeps_rob_renormindics.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/RobustnessDiscrepancy/alldeps_rob_renormindics.jpg
  convert -density $PDFRESOLUTION Figures/RobustnessDiscrepancy/alldeps_robsd_renormindics.pdf -resize "$WIDTH"x -quality $JPGQUALITY Figures/RobustnessDiscrepancy/alldeps_robsd_renormindics.jpg
  montage Figures/RobustnessDiscrepancy/alldeps_rob_renormindics.jpg Figures/RobustnessDiscrepancy/alldeps_robsd_renormindics.jpg -tile 1x2 -geometry +0+"$VERTICALPADDING" $FIGDIR/"$FIGNAME".jpg
  rm Figures/RobustnessDiscrepancy/alldeps_rob_renormindics.jpg Figures/RobustnessDiscrepancy/alldeps_robsd_renormindics.jpg


  ###############
  ## Cybergeo



  # fig:cybergeo:fig1
  FIGNAME=B-cybergeo-fig1
  echo $FIGNAME
  cp Figures/Cybergeo/Fig1.pdf $FIGDIR/"$FIGNAME".pdf

  # fig:cybergeo:fig2
  FIGNAME=B-cybergeo-fig2
  echo $FIGNAME
  cp Figures/Cybergeo/Fig2.pdf $FIGDIR/"$FIGNAME".pdf

  # fig:cybergeo:fig3
  FIGNAME=B-cybergeo-fig3
  echo $FIGNAME
  convert Figures/Cybergeo/Fig3.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:cybergeo:fig4
  FIGNAME=B-cybergeo-fig4
  echo $FIGNAME
  convert Figures/Cybergeo/Fig4.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:cybergeo:fig5
  FIGNAME=B-cybergeo-fig5
  echo $FIGNAME
  convert Figures/Cybergeo/Fig5.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:cybergeo:fig6
  FIGNAME=B-cybergeo-fig6
  echo $FIGNAME
  convert Figures/Cybergeo/Fig6.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:cybergeo:fig7
  FIGNAME=B-cybergeo-fig7
  echo $FIGNAME
  convert Figures/Cybergeo/Fig7.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:cybergeo:fig8
  FIGNAME=B-cybergeo-fig8
  echo $FIGNAME
  convert Figures/Cybergeo/Fig8.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:cybergeo:fig9
  FIGNAME=B-cybergeo-fig9
  echo $FIGNAME
  convert Figures/Cybergeo/Fig9.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:cybergeo:fig10
  FIGNAME=B-cybergeo-fig10
  echo $FIGNAME
  convert Figures/Cybergeo/Fig10.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg



fi


###############
## Appendix C

if [ "$TARGET" == "--C" ] || [ "$TARGET" == "--all" ]
then

  ###############
  ## Cybergeo Networks
  FIGNAME=C-cybergeonetworks-authoring-studied
  echo $FIGNAME
  montage Figures/CybergeoNetworks/authoring.png Figures/CybergeoNetworks/studied.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  FIGNAME=C-cybergeonetworks-who
  echo $FIGNAME
  convert Figures/CybergeoNetworks/who-who.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  FIGNAME=C-cybergeonetworks-commintern
  echo $FIGNAME
  montage Figures/CybergeoNetworks/CommunitiesVertical.png Figures/CybergeoNetworks/Semantic.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  FIGNAME=C-cybergeonetworks-cluster_hadri
  echo $FIGNAME
  montage Figures/CybergeoNetworks/Map_4_studied_hadri_dend.png Figures/CybergeoNetworks/Leg_4_studied_hadri.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:cybergeonetworks:cluster_juste
  FIGNAME=C-cybergeonetworks-cluster_juste
  echo $FIGNAME
  montage Figures/CybergeoNetworks/Map_5_studied_juste_dend.png Figures/CybergeoNetworks/Leg_5_studied_juste.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:cybergeonetworks:perplexity
  FIGNAME=C-cybergeonetworks-perplexity
  echo $FIGNAME
  montage Figures/CybergeoNetworks/perplexity.png Figures/CybergeoNetworks/entropy.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:cybergeonetworks:topics-evolution
  FIGNAME=C-cybergeonetworks-topics-evolution
  echo $FIGNAME
  convert Figures/CybergeoNetworks/evolution.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:cybergeonetworks:cluster_poc
  FIGNAME=C-cybergeonetworks-cluster_poc
  echo $FIGNAME
  montage Figures/CybergeoNetworks/Map_4_studied_poc_dend.png Figures/CybergeoNetworks/Leg_4_studied_poc.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:cybergeonetworks:complementarity
  FIGNAME=C-cybergeonetworks-complementarity
  echo $FIGNAME
  convert Figures/CybergeoNetworks/Sankey_methods_Compared.jpg -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  # -background White -alpha Background : png transparency

  # fig:app:cybergeonetworks:modularities
  FIGNAME=C-cybergeonetworks-modularities
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/CybergeoNetworks/modularities.pdf  -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg



  ###############
  ## Synthetic Data

  # fig:syntheticdata:example_signal
  FIGNAME=C-syntheticdata-example_signal
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/SyntheticData/ex_filtering.pdf -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:syntheticdata:effective_corrs
  FIGNAME=C-syntheticdata-effective_corrs
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/SyntheticData/effectiveCorrs_withGoodTh_A4.pdf -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:syntheticdata:model_perf
  FIGNAME=C-syntheticdata-model_perf
  echo $FIGNAME
  convert -density $PDFRESOLUTION Figures/SyntheticData/pred_filt6.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/SyntheticData/pred_filt6.jpg
  convert -density $PDFRESOLUTION Figures/SyntheticData/pred_filt9.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/SyntheticData/pred_filt9.jpg
  convert -density $PDFRESOLUTION Figures/SyntheticData/pred_filt12.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/SyntheticData/pred_filt12.jpg
  convert -density $PDFRESOLUTION Figures/SyntheticData/lagged_corrs.pdf -resize "$((WIDTH / 2))"x -quality $JPGQUALITY Figures/SyntheticData/lagged_corrs.jpg
  montage Figures/SyntheticData/pred_filt6.jpg Figures/SyntheticData/pred_filt9.jpg Figures/SyntheticData/pred_filt12.jpg Figures/SyntheticData/lagged_corrs.jpg -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" $FIGDIR/"$FIGNAME".jpg
  rm Figures/SyntheticData/pred_filt6.jpg Figures/SyntheticData/pred_filt9.jpg Figures/SyntheticData/pred_filt12.jpg Figures/SyntheticData/lagged_corrs.jpg

  ###############
  ## Patents Mining

  # fig:patentsmining:networksensitivity
  FIGNAME=C-patentsmining-networksensitivity
  echo $FIGNAME
  convert Figures/PatentsMining/Fig1.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:patentsmining:rawnetwork
  FIGNAME=C-patentsmining-rawnetwork
  echo $FIGNAME
  convert Figures/PatentsMining/Fig2.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:patentsmining:mean_K
  FIGNAME=C-patentsmining-mean_K
  echo $FIGNAME
  convert Figures/PatentsMining/Fig3.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:patentsmining:class-sizes
  FIGNAME=C-patentsmining-class-sizes
  echo $FIGNAME
  convert Figures/PatentsMining/Fig4.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:patentsmining:patent-level-orig
  FIGNAME=C-patentsmining-patent-level-orig
  echo $FIGNAME
  convert Figures/PatentsMining/Fig5.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:patentsmining:orig-gene
  FIGNAME=C-patentsmining-orig-gene
  echo $FIGNAME
  convert Figures/PatentsMining/Fig6.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:patentsmining:intra-classif-overlap
  FIGNAME=C-patentsmining-intra-classif-overlap
  echo $FIGNAME
  convert Figures/PatentsMining/Fig7.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:patentsmining:inter-classif-overlap
  FIGNAME=C-patentsmining-inter-classif-overlap
  echo $FIGNAME
  convert Figures/PatentsMining/Fig8.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:patentsmining:modularities
  FIGNAME=C-patentsmining-modularities
  echo $FIGNAME
  convert Figures/PatentsMining/Fig9.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg


  ################
  ## Mediation Ecotox

  # fig:app:mediationecotox:boardgame
  FIGNAME=C-mediationecotox-boardgame
  echo $FIGNAME
  convert Figures/MediationEcotox/boardgame.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:mediationecotox:phasediags
  FIGNAME=C-mediationecotox-phasediags
  echo $FIGNAME
  convert Figures/MediationEcotox/phasediags.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:mediationecotox:webpage
  FIGNAME=C-mediationecotox-webpage
  echo $FIGNAME
  convert Figures/MediationEcotox/webpage.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  ################
  ## Migration dynamics

  # fig:app:migrationdynamics:model
  FIGNAME=C-migrationdynamics-model
  echo $FIGNAME
  montage Figures/MigrationDynamics/model.png Figures/MigrationDynamics/examples.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 -border 2 -bordercolor Black $FIGDIR/"$FIGNAME"_tmp.png
  convert $FIGDIR/"$FIGNAME"_tmp.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
  rm $FIGDIR/"$FIGNAME"_tmp.png

  # fig:app:migrationdynamics:results
  FIGNAME=C-migrationdynamics-results
  echo $FIGNAME
  montage -resize "$(( WIDTH / 3))"x Figures/MigrationDynamics/baseline_jobdist0.png -resize "$((2 * WIDTH / 3))"x Figures/MigrationDynamics/real_indicjobDistance0_smoothed.png -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 $FIGDIR/"$FIGNAME".jpg




fi


###############
## Appendix F

if [ "$TARGET" == "--F" ] || [ "$TARGET" == "--all" ]
then

  # fig:app:reflexivity:citnw
  FIGNAME=F-reflexivity-citnw
  echo $FIGNAME
  convert Figures/Reflexivity/citcore.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:reflexivity:interdisc
  FIGNAME=F-reflexivity-interdisc
  echo $FIGNAME
  convert Figures/Reflexivity/interdisciplinarities.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg

  # fig:app:reflexivity:time
  FIGNAME=F-reflexivity-time
  echo $FIGNAME
  montage Figures/Reflexivity/weekly-macroproj.png Figures/Reflexivity/weekly-chapter.png Figures/Reflexivity/weekly-knowledgedomains.png -resize "$WIDTH"x -quality $JPGQUALITY -tile 1x3 -geometry +0+"$VERTICALPADDING" $FIGDIR/"$FIGNAME".jpg

  # fig:app:reflexivity:projects
  FIGNAME=F-reflexivity-projects
  echo $FIGNAME
  montage -resize "$(( WIDTH / 2))"x Figures/Reflexivity/graph-projects-cooccs.png -resize "$(( WIDTH / 2))"x Figures/Reflexivity/graph-projects-laggedflow.png -quality $JPGQUALITY -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 $FIGDIR/"$FIGNAME".jpg

  # fig:app:reflexivity:kd
  FIGNAME=F-reflexivity-kd
  echo $FIGNAME
  montage -resize "$(( WIDTH / 2))"x Figures/Reflexivity/graph-kd-cooccs.png -resize "$(( WIDTH / 2))"x Figures/Reflexivity/graph-kd-laggedflow.png -quality $JPGQUALITY -tile 2x1 -geometry +"$HORIZONTALPADDING"+0 $FIGDIR/"$FIGNAME".jpg

  # fig:app:reflexivity:laggedcorrs
  FIGNAME=F-reflexivity-laggedcorrs
  echo $FIGNAME
  convert Figures/Reflexivity/laggedcorrs.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg


fi





osascript -e 'display notification "Finished figures for chapter '$TARGET'" with title "Figures generation"'
