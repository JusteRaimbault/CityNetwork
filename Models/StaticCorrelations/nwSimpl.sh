# pb : in sudo, env vars not defined by .bashrc
# ok superuser role
#CN_HOME=/home/juste/ComplexSystems/CityNetwork
#DATADIR=$CN_HOME/Data/OSM
DATADIR=test

# sql simplbase schema
psql -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'nw';"
psql -c "DROP DATABASE nw;"
psql -c "CREATE DATABASE nw;"
psql -d nw -f sql/simpl_schema.sql

ls $DATADIR | awk '{print "./nwSimplCountry.sh $CN_HOME/Data/OSM/"$1}' | sh

