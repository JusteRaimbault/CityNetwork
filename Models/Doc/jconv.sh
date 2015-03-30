#!/bin/sh

#  jconv.sh
#  
#
#  Created by Juste Raimbault on 30/03/15.

# convert a given file from formatted NL to brute java

# restrictive conditions for comment bloc : begin and end lines == ';;' (too much garbage if not imposed)

FILE=$1
OUT_PREFIX=$(echo $FILE | awk -F".nls" '{print $1}')
OUT=$OUT_PREFIX".java"
touch $OUT

# parse the nls file and outputs in java file
echo "public class "$OUT_PREFIX"{\n" > $OUT

# read lines and detect primitives

OUT_PRIM=1
OUT_COMMENT=1
while read line
do
 
  ENTERS_PRIM=`echo $line | grep '^to' | grep -v ";" | wc -l`
  if [ $ENTERS_PRIM = 1 ] && [ $OUT_PRIM = 1 ];then
     echo "public static "`echo $line | awk -F" " '{print $2}'`"(){\n"  >> $OUT
     OUT_PRIM=0
  fi

  END_PRIM=`echo $line | grep "^end" | grep -v ";" | wc -l`
  if [ $END_PRIM = 1 ] && [ $OUT_PRIM = 0 ];then
    echo "}\n" >> $OUT
    OUT_PRIM=1
  fi

  # if in comment block
  if [ $OUT_COMMENT = 0 ];then
    echo "* "`echo $line | awk -F";" '{print $2}'` >> $OUT
  fi

  TOGGLE_COMMENT=`echo $line | grep '^;;$' | wc -l`
if [ $TOGGLE_COMMENT = 1 ];then
    if [ $OUT_COMMENT = 1 ];then
      echo "/**"  >> $OUT
      OUT_COMMENT=0
    else
      echo "*/"  >> $OUT
      OUT_COMMENT=1
    fi
  fi


done < $FILE



echo "}" >> $OUT

