#!/bin/sh

#  algoSR.sh
#     $1 : basedir. Should contain credential, keywords, etc
#
#  Requires :
#     - jsawk
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
# dangerous
appID=`cat appID`
appSecret=`cat appSecret`

# request auth token
accessToken=$(curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -u $appID:$appSecret -d "grant_type=client_credentials&scope=all" https://api.mendeley.com/oauth/token| jsawk 'return this.access_token')
#echo $accessToken #OK

# try a search request
query='urban+form'

curl 'https://api.mendeley.com/search/catalog?query='$query'&limit=10' \
-H 'Authorization: Bearer '$accessToken \
-H 'Accept: application/vnd.mendeley-document.1+json' \
#| jsawk 'out(this.abstract+"\n\n\n");return null'





#############
## Try access Cortext ?
#############
#
# Text processing procedure given in [Chavalarias, Cointet, 2012]-S1
# Seems to be heavy to locally extract n-grams (although Java NLP many libraries available, see e.g. Stanford-NLP )
#
# Cortext "API" should be handled by hand, making adapted requests and parsing http responses.
#    -> go to Java, not possible in shell.
#


# back to initial dir : not necessary
#cd $initialDir