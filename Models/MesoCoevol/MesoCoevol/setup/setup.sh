head -n 2 setup/coordstmp.csv > setup/coordstmp2.csv
rm setup/coordstmp.csv
mv setup/coordstmp2.csv setup/coordstmp.csv
#R -e "source('r/morpho.R');writeTempRaster()"
/usr/local/bin/R -e "source('r/morpho.R');writeTempRaster()"
rm setup/coordstmp.csv

