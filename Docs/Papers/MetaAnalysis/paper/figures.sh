
PDFRESOLUTION=1000
WIDTH=2000
HORIZONTALPADDING=10
VERTICALPADDING=10
JPGQUALITY=70

# Fig 1
convert -density $PDFRESOLUTION "$CN_HOME"/Models/Theory/systematicreview.pdf -background white -alpha background -alpha off -resize "$WIDTH"x -quality $JPGQUALITY figures/Fig1.jpg

# Fig 2
convert -density $PDFRESOLUTION "$CN_HOME"/Models/Theory/coevolution.pdf -background white -alpha background -alpha off -resize "$WIDTH"x -quality $JPGQUALITY figures/Fig2.jpg

# Fig App
FIGDIR="$CN_HOME"/Docs/ThesisMemoire/Final/Figures/QuantEpistemo/
montage "$FIGDIR"/lm_adjr2-aicc_INTERDISC.pdf "$FIGDIR"/lm_adjr2-aicc_SPATSCALE.pdf "$FIGDIR"/lm_adjr2-aicc_TEMPSCALE.pdf "$FIGDIR"/lm_adjr2-aicc_YEAR.pdf -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" figures/Fig3_tmp.pdf
convert -density $PDFRESOLUTION figures/Fig3_tmp.pdf -resize "$WIDTH"x -quality $JPGQUALITY figures/Fig3.jpg
rm figures/Fig3_tmp.pdf
