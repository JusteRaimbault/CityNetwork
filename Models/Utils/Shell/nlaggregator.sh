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
#
#  NOTE : first line  of model MUST be empty (issue with read ?)

MODEL=$1
SOURCE_DIR=$2

###############
# create output model
###############
if [ -f "WRAPPED_"$MODEL ]
then
  rm "WRAPPED_"$MODEL
fi

touch "WRAPPED_"$MODEL


# number of lines in original file
LINES=`cat $MODEL | wc | awk '{print $1}'`


# output source ; taken from nl latex script
# pb with first line : why ?
#
# We use the separator for section in nlogo plain files
#
while read line
do
  LN=`grep -n "\@\#\$\#\@\#\$\#\@" $line| head -n 1 | awk -F ':' '{print $1}'`
#LN="$((LN + 1))"
#  head -n $LN $model > $queue
done < $MODEL

LN="$((LN + 1))"
#echo $LN

# needs to find line beginning includes
# grep on pattern  __includes

while read line
do
LN_INCLUDES=`grep -n "__includes" $line| head -n 1 | awk -F ':' '{print $1}'`
done < $MODEL

# then first closing bracket is end of includes
# taking tail of file only
printf "\n" > tmp
tail -n $((LINES - LN_INCLUDES)) $MODEL >> tmp
#head -n 30 tmp

while read line
do
LN_END_INCLUDES=`grep -n "\]" $line| head -n 1 | awk -F ':' '{print $1}'`
done < tmp
#echo $LN_END_INCLUDES
rm tmp

# echoes base code in wrapped file
head -n $LN_INCLUDES $MODEL >> "WRAPPED_"$MODEL

tail -n $((LINES - LN_INCLUDES - LN_END_INCLUDES)) $MODEL | head -n $((LN  - LN_END_INCLUDES - LN_INCLUDES - 1)) >> "WRAPPED_"$MODEL

###########
# echo external sources
###########

# include only *.nls files in provided directory
ORIG=`pwd`
cd $SOURCE_DIR
touch tmp
ls | grep .nls | awk '{print "cat "$1" >> tmp"}' | sh

# back
cd $ORIG
#cat $SOURCE_DIR"/tmp"
cat $SOURCE_DIR"/tmp" >> "WRAPPED_"$MODEL
rm $SOURCE_DIR"/tmp"


###########
# echo end of model
###########

# first additional lines for security
#echo "\n\n" >> "WRAPPED_"$MODEL
# NO, depending on platform, new line character is understood differently, leads to error on Centos whereas ok on OSX
#
#  add lines at beginning/end of source files for more clarity of resulting code.
#  Rq : printf seems to interpret it correctly ?


#cat "WRAPPED_"$MODEL

#echo $((LINES - LN))
tail -n $((LINES - LN + 1)) $MODEL >> "WRAPPED_"$MODEL

# OK





