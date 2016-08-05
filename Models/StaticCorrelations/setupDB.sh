DBNAME=$1
DBPORT=5433

psql -p $DBPORT -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DBNAME';"
psql -p $DBPORT -d postgres -c "DROP DATABASE $DBNAME;"
psql -p $DBPORT -d postgres -c "CREATE DATABASE $DBNAME;"
psql -p $DBPORT -d $DBNAME -f sql/simpl_schema.sql


