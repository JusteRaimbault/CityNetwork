
#
#39.953497, -2.994754
# 40.671445, -3.375470 for better balance


DIR=$1
INPUT=$2

osmosis --read-pbf $INPUT --tee 4 \
  --bounding-box left=-3.375470 top=40.671445 --write-pbf $DIR/se.pbf \
  --bounding-box left=-3.375470 bottom=40.671445 --write-pbf $DIR/ne.pbf \
  --bounding-box right=-3.375470 top=40.671445 --write-pbf $DIR/sw.pbf \
  --bounding-box right=-3.375470 bottom=40.671445 --write-pbf $DIR/nw.pbf \

