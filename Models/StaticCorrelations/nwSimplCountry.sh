#pbf file
FILE=$1
echo "PROCESSING FILE : "$FILE

# drop old base
psql -c "DROP DATABASE osm;"
# recreates it
psql -c "CREATE DATABASE osm"

# create extensions : must be superuser -> run script with sudo
psql -d osm -c "CREATE EXTENSION postgis;CREATE EXTENSION hstore;"

# load osm schemas
psql -d osm -f sql/pgsnapshot_schema_0.6.sql
psql -d osm -f sql/pgsnapshot_schema_0.6_linestring.sql

# pbf to postgis
osmosis --read-pbf $FILE --log-progress --tf accept-ways highway=* --used-node --write-pgsql database=osm user=juste password=`cat sql/password`

# R simplification process
R -f nwSimplification.R

