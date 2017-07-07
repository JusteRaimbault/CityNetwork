# -*- coding: utf-8 -*-
import os,nltk,time,locale,sys,utils
from treetagger import TreeTagger
from langdetect import detect



#
def run_kw_extraction(source,target) :
    if source=='--mysql':
        kw_extraction(utils.get_data('SELECT id,abstract FROM refdesc WHERE abstract_keywords IS NULL;','mysql'),'mysql','abstract')
        #kw_extraction(data,'full')
    else :
        # only csv alternate sources for now ; exports
        corpus = utils.corpus_from_csv(source,";")
        # convert corpus
        raw = []
        for ref in corpus :
            raw.append([ref['id'],ref['title']+' '+ref['abstract']])
        kw_extraction(raw,target,'abstract')



def kw_extraction(data,target,text_type):
    if target!='mysql': # init the sqlite db
        os.remove(target)
        utils.insert_sqlite("CREATE TABLE refdesc (id TEXT,language TEXT,abstract_keywords TEXT,abstract TEXT);",target)
    for ref in data:
        print(ref)
        if ref[1] is not None:
            language = get_language(ref[1])
            keywords = extract_keywords(ref[1],ref[0],language)
            kwtext = ""
            for multistem in keywords:
	            kwtext=kwtext+reduce(lambda s1,s2 : s1+' '+s2,multistem)+";"
                #print(kwtext)
            if target=='mysql':
                if text_type=='abstract':
                    utils.query_mysql("INSERT INTO refdesc (id,language,abstract_keywords,abstract) VALUES (\'"+ref[0].encode('utf8')+"\',\'"+language.encode('utf8')+"\',\'"+kwtext+"\',\'"+ref[1].encode('utf8')+"\') ON DUPLICATE KEY UPDATE language = VALUES(language),abstract_keywords=VALUES(abstract_keywords),abstract=VALUES(abstract);")
                else :
                    utils.query_mysql("INSERT INTO refdesc (id,fulltext_keywords) VALUES (\'"+ref[0].encode('utf8')+"\',\'"+ref[1].encode('utf8')+"\') ON DUPLICATE KEY UPDATE fulltext_keywords = VALUES(fulltext_keywords);")
            else :
                utils.insert_sqlite("INSERT INTO refdesc (id,language,abstract_keywords,abstract) VALUES (\'"+ref[0]+"\',\'"+language+"\',\'"+kwtext+"\',\'"+ref[1]+"\');",target)




def potential_multi_term(tagged,language):
    languages = ['en','fr']
    res = True
    for tag in tagged :
        if len(tag)>=2 :
            if language=='en':
                res = res and (tag[1]=="NN" or tag[1]=="NNP" or tag[1] == "VBG" or tag[1] =="NNS" or tag[1] =="JJ" or tag[1] =="JJR")
            if language=='fr' :
                res = res and (tag[1]=='NOM' or tag[1]=='ADJ') and len(tag[0]) >= 3 #and tag[2]!="<unknown>"
            if language not in languages :
                res = False
        else :
            res=False
    return res


#STOPWORDS_DICT = dict()
#for lang in nltk.corpus.stopwords.fileids():
#    STOPWORDS_DICT[lang] =  set(nltk.corpus.stopwords.words(lang))

def get_language(text):
    #words = set(nltk.wordpunct_tokenize(text.lower()))
    #return max(((lang, len(words & stopwords)) for lang, stopwords in STOPWORDS_DICT.items()), key = lambda x: x[1])[0]
    return(detect(text))


def extract_keywords(raw_text,id,language):

    print("Extracting keywords for "+id)

    stemmer = nltk.PorterStemmer()

    if language == 'en':
        tokens = nltk.word_tokenize(raw_text)
        # filter undesirable words and format
        words = [w.replace('\'','') for w in tokens if len(w)>=3]
        text = nltk.Text(words)
        tagged_text = nltk.pos_tag(text)
    else:
        ttlangdico = {'fr':'french'}
        if language in ttlangdico :
            tt = TreeTagger(language=ttlangdico[language])
        else :
            tt = TreeTagger()
        tagged_text =tt.tag(raw_text.replace('\'',' ').replace(u'\u2019',' ').replace(u'\xab',' ').replace(u'\xbb',' '))

    print(tagged_text)

    # detect language using stop words, adapt filtering/stemming technique in function

    # multi-term
    multiterms = []
    for i in range(len(tagged_text)) :
  #      # max length 4 for multi-terms
        for l in range(1,5) :
            if i+l < len(tagged_text) :
                tags = [tagged_text[k] for k in range(i,i+l)]
                if potential_multi_term(tags,language) :
                    multistem = []
                    if language == 'en':
                        multistem = [str.lower(stemmer.stem(tagged_text[k][0]).encode('utf8','ignore')) for k in range(i,i+l)]
                    else :#in case of french or other languages, terms are already stemmed by TreeTagger
                        for k in range(i,i+l):
                            if tagged_text[k][2]!="<unknown>":
                                stem = tagged_text[k][2]
                            else :
                                stem = tagged_text[k][0]
                            multistem.append(str.lower(stem.encode('utf8','ignore')))
                    multiterms.append(multistem)
    return multiterms
