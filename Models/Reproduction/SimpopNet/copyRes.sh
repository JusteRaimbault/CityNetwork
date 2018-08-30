DIR=$1
mkdir calib/$DIR
for i in `seq 1 1000 17000`; do cp calibration/$DIR/population$i.csv calib/$DIR ; done
