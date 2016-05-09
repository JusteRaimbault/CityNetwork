#pbf file
FILE=$1
echo "PROCESSING FILE : "$FILE
DB=`echo $FILE | awk -F/ '{print $(NF-1)}'`

echo "DB : $DB"
#echo `pwd`

DB=test

# drop old base
psql -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '"$DB"';"
psql -c "DROP DATABASE "$DB";"
# recreates it
psql -c "CREATE DATABASE "$DB";"

# create extensions : must be superuser -> run script with sudo
psql -d $DB -c "CREATE EXTENSION postgis;CREATE EXTENSION hstore;"

# load osm schemas
psql -d $DB -f sql/pgsnapshot_schema_0.6.sql
psql -d $DB -f sql/pgsnapshot_schema_0.6_linestring.sql

# pbf to postgis
osmosis --read-pbf $FILE --log-progress --tf accept-ways highway=* --used-node --write-pgsql database=$DB user=juste password=`cat sql/password`

# R simplification process
R -e "osmdb='$DB';source('nwSimplification.R',local=TRUE)"

