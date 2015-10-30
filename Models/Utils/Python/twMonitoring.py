
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




def validate_tweet(text):
    #reg_mail = re.compile(reduce(lambda s1,s2 : s1+s2,[s[:-1] for s in open('regex_mail','r').readlines()]))
    reg_mail = re.compile(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)")

    for i in range(0,len(text)-1):
        for j in range(i+1,len(text)):
            if reg_mail.match(text[i:j]) : return(True)
    return(False)



def main():

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

        search = ts.search_tweets_iterable(tso)

        # get previous request ids from file --DIRTY--
        previous = open('previous','r')
        prev = dict()
        for i in [s.replace('\n','') for s in previous.readlines()]:
            prev[i]=i

        #print(search.keys())
        prev_write = open('previous','w')

        #reg_mail = re.compile(reduce(lambda s1,s2 : s1+s2,[s[:-1] for s in open('regex_mail','r').readlines()]))

        mail = open('mail','r').readline().replace('\n','')
        pwd = open('pwd','r').readline().replace('\n','')
        s = smtplib.SMTP('smtp.gmail.com',587)
        s.starttls()
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

        if len(mail_text) > 0 :
            msg = MIMEText(mail_text.encode('utf-8'), 'plain', 'utf-8')
            msg['Subject'] = 'Latest #ICanHazPdf requests...'
            msg['From'] = mail
            msg['To'] = mail
            s.sendmail(mail,mail,msg.as_string())

        s.close()



    except TwitterSearchException as e:
        print(e)





main()
