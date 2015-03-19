#!/bin/sh

#  nlaggregator.sh
#  
#
#  Created by Juste Raimbault on 19/03/15.
#
#  Takes a NetLogo model with external sources and creates a single *.nlogo file 
#    wrapping all code, to be used by openmole, as "WRAPPED_"modelname.nlogo
#
#  args : $1 .nlogo model , $2 folder containing sources

MODEL=$1
SOURCE_DIR=$2

# create output model
if [ -f "WRAPPED_"$MODEL ]
then
  rm "WRAPPED_"$MODEL
fi

touch "WRAPPED_"$MODEL

# output source ; taken from nl latex script
# pb with first line : why ?
while read line
do
  LN=`grep -n "\@\#\$\#\@\#\$\#\@" $line| head -n 1 | awk -F ':' '{print $1}'`
#LN="$((LN + 1))"
#  head -n $LN $model > $queue
done < $MODEL

#echo $LN

# echoes base code in wrapped file
head -n $LN $MODEL >> "WRAPPED_"$MODEL

# echo external sources
# include only *.nls files
ORIG=`pwd`
cd $SOURCE_DIR
touch tmp
ls | grep .nls | awk '{print "cat "$1" > tmp"}' | sh

# back
cd $ORIG
cat $SOURCE_DIR"/tmp" >> "WRAPPED_"$MODEL

# echo end of model
# first additional lines for security
echo "\n\n" >> "WRAPPED_"$MODEL

LINES=`cat $MODEL | wc | awk '{print $1}'`
#echo $((LINES - LN))
tail -n $((LINES - LN)) $MODEL >> "WRAPPED_"$MODEL

# OK





