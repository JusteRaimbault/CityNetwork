#!/usr/bin/env python

# python twitter search deamon
#
# Use : keywords in 'keywords' file
#       conf file contains : consumer_key,consumer_secret,access_token,access_token_secret
#


from TwitterSearch import *
#from validate_email import validate_email
import re
import smtplib
from email.mime.text import MIMEText

#print('test')


def validate_tweet(text):
    #reg_mail = re.compile(reduce(lambda s1,s2 : s1+s2,[s[:-1] for s in open('regex_mail','r').readlines()]))
    reg_mail = re.compile(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)")

    for i in range(0,len(text)-1):
        for j in range(i+1,len(text)):
            if reg_mail.match(text[i:j]) : return(True)
    return(False)


# read a conf file under the format key:value
# , returns a dictionary
def read_conf(file):
    conf = open('conf','r')
    res=dict()
    currentLine = conf.readline().replace('\n','')
    while currentLine != '' :
        t=str.split(currentLine,':')
        if len(t) != 2 : raise Exception('error in conf file')
        res[t[0]]=t[1]
        currentLine = conf.readline().replace('\n','')
        #print(t[0]+' : '+t[1])
    return(res)


def main():

    print('running main')

    try:
        tso = TwitterSearchOrder()

        kwFile = open('keywords','r')
        keywords=kwFile.readlines()

        tso.set_keywords([s.replace('\n','') for s in keywords])

        conf = read_conf('conf')
        key = conf['key']
        secret = conf['secret']
        token = conf['token']
        token_secret = conf['token_secret']

	print('conf read')

        ts = TwitterSearch(
                consumer_key = key,
                consumer_secret = secret,
                access_token = token,
                access_token_secret = token_secret
                )

        search = ts.search_tweets_iterable(tso)

	print('search ok')

        # get previous request ids from file --DIRTY--
        previous = open('previous','r')
        prev = dict()
        for i in [s.replace('\n','') for s in previous.readlines()]:
            prev[i]=i

        #print(search.keys())
        prev_write = open('previous','w')

	print('prev ok')

        mail =  conf['mail']
        pwd = conf['pwd']
        s = smtplib.SMTP(conf['smtp_host'],int(conf['smtp_port']))
        s.starttls()

	print('smtp started')

        s.login(mail,pwd)

        mail_text = ''

        for tweet in ts.search_tweets_iterable(tso):
            prev_write.write(str(tweet['id'])+'\n')
            if not str(tweet['id']) in prev :
                if len(tweet['entities']['urls']) > 0 and validate_tweet(tweet['text']):
                    #print(tweet)
                    mail_text=mail_text+'\n\nTWEET AT '+tweet['created_at']
                    mail_text=mail_text+tweet['text']

        prev_write.close()

        # get mail adresses
        mails = open('mails','r').readlines()

        if len(mail_text) > 0 :
            for to_mail in mails :
                msg = MIMEText(mail_text.encode('utf-8'), 'plain', 'utf-8')
                msg['Subject'] = 'Latest #ICanHazPdf requests...'
                msg['From'] = mail
                msg['To'] = to_mail
                s.sendmail(mail,mail,msg.as_string())

	#print(mail_text)
        s.close()



    except TwitterSearchException as e:
        print(e)


print('test')

main()
