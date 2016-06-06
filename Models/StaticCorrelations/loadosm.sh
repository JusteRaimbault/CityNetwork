FILE=$1
DB=$2

echo "DB : $DB"
#echo `pwd`

#DB=test

# drop old base
psql -p 5433 -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '"$DB"';"
psql -p 5433 -c "DROP DATABASE "$DB";"
# recreates it
psql -p 5433 -c "CREATE DATABASE "$DB";"

# create extensions : must be superuser -> run script with sudo
psql -p 5433 -d $DB -c "CREATE EXTENSION postgis;CREATE EXTENSION hstore;"

# load osm schemas
psql -p 5433 -d $DB -f sql/pgsnapshot_schema_0.6.sql
psql -p 5433 -d $DB -f sql/pgsnapshot_schema_0.6_linestring.sql

# pbf to postgis
osmosis --read-pbf $FILE --log-progress --tf accept-ways highway=* --used-node --write-pgsql host=localhost:5433 database=$DB user=juste password=`cat sql/password`




