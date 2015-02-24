#!/bin/sh

#  algoSR.sh
#     $1 : basedir. Should contain credential, keywords, etc
#
#
#  Created by <a href="mailto:juste.raimbault@polytechnique.edu">Juste Raimbault</a> on 24/02/15.
#  
#
#


# Test for automatized iterative Systematic Review

# move to basedir
initialDir=`pwd`
cd $1

##############
## try a Mendeley API keywords request
##############

# ¡ do not forget to put files in gitignore !
appID=`cat appID`
appSecret=`cat appSecret`

# request auth token
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -u $appID:$appSecret -d "grant_type=client_credentials&scope=all" https://api.mendeley.com/oauth/token






# back to initial dir : not necessary
#cd $initialDir