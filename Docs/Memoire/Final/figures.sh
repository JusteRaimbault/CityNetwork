
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
## Chapitre 4

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

fi



###############
## Chapitre 4

if [ "$TARGET" == "--4" ] || [ "$TARGET" == "--all" ]
then

###############
## 4.2 : Spatio-temp causalities

# fig:causalityregimes:exrdb
FIGNAME=4-2-2-fig-causalityregimes-exrdb
echo $FIGNAME
convert Figures/CausalityRegimes/laggedcorrs_facetextreme.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/laggedcorrs_facetextreme.jpg
montage Figures/CausalityRegimes/ex_60_wdens0_wroad1_wcenter1_seed272727.png Figures/CausalityRegimes/ex_60_wdens1_wroad1_wcenter0_seed272727.png Figures/CausalityRegimes/ex_60_wdens1_wroad1_wcenter1_seed272727.png -tile 3x1 -geometry +"$HORIZONTALPADDING"+0 Figures/Final/fig-causalityregimes-exrdb_tmp.png
convert Figures/Final/fig-causalityregimes-exrdb_tmp.png -resize "$WIDTH"x -quality $JPGQUALITY Figures/Final/fig-causalityregimes-exrdb_tmp.jpg
rm $FIGDIR/fig-causalityregimes-exrdb_tmp.png
montage Figures/Final/fig-causalityregimes-exrdb_tmp.jpg Figures/Final/laggedcorrs_facetextreme.jpg -tile 1x2 -geometry +0+"$HORIZONTALPADDING" -quality $JPGQUALITY $FIGDIR/"$FIGNAME".jpg
rm $FIGDIR/fig-causalityregimes-exrdb_tmp.jpg
rm $FIGDIR/laggedcorrs_facetextreme.jpg


# fig:causalityregimes:clustering
#FIGNAME=4.2.2-fig-causalityregimes-clustering
#echo $FIGNAME
#montage Figures/CausalityRegimes/ccoef-knum_valuesFALSE_theta05-3.pdf Figures/CausalityRegimes/dccoef-knum_valuesFALSEtheta05-3.pdf -tile 3x1 -geometry +"$HORIZONTALPADDING"+0 $FIGDIR/"$FIGNAME"_tmp.pdf
#convert -density $PDFRESOLUTION Figures/CausalityRegimes/ccoef-knum_valuesFALSE_theta05-3.pdf -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/"$FIGNAME"_tmp.jpg

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



fi
