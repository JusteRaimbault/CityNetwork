DB_PORT=5433
DB_USER=juste
OSMOSIS=/home/juste/bin/osmosis

FILE=$1
DB_NAME=$2

PASSWORD=`cat sql/password`
sudo $OSMOSIS --read-pbf $FILE --log-progress --tf accept-ways highway=* --used-node --write-pgsql host="localhost:$DB_PORT" database="$DB_NAME" user="$DB_USER" password="$PASSWORD"

