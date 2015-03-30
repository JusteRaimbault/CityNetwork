#!/bin/sh

#  nl2java.sh
#  
#
#  Created by Juste Raimbault on 30/03/15.


# Tests for lighweight filter to feed Doxygen with NL sources

SOURCE_DIR=$1
OUT_DIR=$2

ORIG=`pwd`
cd $SOURCE_DIR
ls | grep .nls | awk '{print "../jconv.sh "$1}' | sh

cd $ORIG

mkdir $OUT_DIR

mv $SOURCE_DIR"*.java" $OUT_DIR
