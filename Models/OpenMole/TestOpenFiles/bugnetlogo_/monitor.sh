#!/bin/sh
# monitoring of open files

PID=$1
# jar path ? -> monitor all jars ? both to be tried
JARPATH=$2
OUTFILE=$3

while true
do
   lsof -p $PID | grep $JARPATH | wc -l >> $OUTFILE
   sleep 0.5
done




