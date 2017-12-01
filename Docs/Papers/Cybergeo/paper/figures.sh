# general
FIGDIR=figures

# quality
JPGQUALITY=50
PDFRESOLUTION=200

# size parameters
WIDTH=2000
HORIZONTALPADDING=10
VERTICALPADDING=10


# Fig1
#convert -density $PDFRESOLUTION figuresraw/archi.pdf -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/Fig1.jpg
cp figuresraw/archi.pdf $FIGDIR/Fig1.pdf

# Fig2
#convert -density $PDFRESOLUTION figuresraw/citnw.pdf -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/Fig2.jpg
cp figuresraw/citnw.pdf $FIGDIR/Fig2.pdf

# Fig3
convert -density $PDFRESOLUTION figuresraw/ranksize.pdf -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/Fig3.jpg

# Fig4
convert figuresraw/cybclic.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/Fig4.jpg

# Fig5
convert figuresraw/core.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/Fig5.jpg

# Fig6
montage figuresraw/sensitivity_balance_freqmin50_freqmax10000.png figuresraw/sensitivity_communities_freqmin50_freqmax10000.png figuresraw/sensitivity_modularity_freqmin50_freqmax10000.png figuresraw/sensitivity_vertices_freqmin50_freqmax10000.png -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/Fig6.jpg

# Fig7
convert figuresraw/semantic.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/Fig7.jpg

# Fig8
convert -density $PDFRESOLUTION figuresraw/synththemcyb.pdf -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/Fig8.jpg

# Fig9
convert figuresraw/compo_proportion.png -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/Fig9.jpg

# Fig10
montage figuresraw/originalities_citclass.png figuresraw/citation_originalities_citclass.png -tile 1x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize "$WIDTH"x -quality $JPGQUALITY $FIGDIR/Fig10.jpg





#
