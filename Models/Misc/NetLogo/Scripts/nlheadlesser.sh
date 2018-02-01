#!/bin/sh

#  nlheadlesser.sh
#  
#
#  Created by Juste Raimbault on 22/05/15.
#
#  Prepares a gui model to be run headlessly
#
#  Arg : $1 : .nlogo model

MODEL=$1

if [ -f "HEADLESS_"$MODEL ]
then
rm "HEADLESS_"$MODEL
fi

touch "HEADLESS_"$MODEL



