FILE=$1
TAG=$2
#highway
osmosis --read-xml $FILE.osm --log-progress --tf accept-ways $TAG=* --used-node --write-xml "$FILE_$TAG".osm



