
# python twitter search deamon
#
# Use : keywords in 'keywords' file
#       conf file contains : consumer_key,consumer_secret,access_token,access_token_secret
#


from TwitterSearch import *


try:
    tso = TwitterSearchOrder()

    kwFile = open('keywords','r')
    keywords=kwFile.readlines()

    tso.set_keywords([s.replace('\n','') for s in keywords])

    conf = open('conf','r')
    key = conf.readline().replace('\n','')
    secret = conf.readline().replace('\n','')
    token = conf.readline().replace('\n','')
    token_secret = conf.readline().replace('\n','')

    ts = TwitterSearch(
            consumer_key = key,
            consumer_secret = secret,
            access_token = token,
            access_token_secret = token_secret
        )

    for tweet in ts.search_tweets_iterable(tso):
        print('@%s tweeted: %s' % (tweet['user']['screen_name'], tweet['text']))

except TwitterSearchException as e:
    print(e)
