#!/bin/sh

#  nl2java.sh
#  
#
#  Created by Juste Raimbault on 30/03/15.


# Tests for lighweight filter to feed Doxygen with NL sources

SOURCE_DIR=$1

ORIG=`pwd`
cd $SOURCE_DIR
ls | grep .nls | awk '{print "../jconv.sh "$1}' | sh

cd $ORIG


