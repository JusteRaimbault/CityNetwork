# pb : in sudo, env vars not defined by .bashrc
# ok superuser role
#CN_HOME=/home/juste/ComplexSystems/CityNetwork
#DATADIR=$CN_HOME/Data/OSM
DATADIR=test

# sql simplbase schema
#psql -c "DROP DATABASE nw;CREATE DATABASE nw;"
createdb nw
psql -d nw -f sql/simpl_schema.sql

ls $DATADIR/* | awk '{print "./nwSimplCountry.sh "$1}' | sh

