#!/bin/sh

# count code lines in a directory

DIRECTORY=$1

cd $DIRECTORY

#COUNT=0

#while read line
#do
#  COUNT="$((COUNT + $line))"
#  echo $COUNT
#done < ``

find . -type f | grep -f $CN_HOME/Models/Utils/Shell/codelines/codetype | grep -v -f $CN_HOME/Models/Utils/Shell/codelines/exclude | awk '{print "cat "$1" | wc -l"}' | sh | awk '{s+=$1} END {print s}'

#echo $COUNT
