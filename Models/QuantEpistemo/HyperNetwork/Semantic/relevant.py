# -*- coding: utf-8 -*-

# bootstrap for relevant terms extraction

import numpy,os,pymongo,math
import kwFunctions,utils,butils



def relevant_full_corpus(kwLimit,eth):
    #corpus = utils.get_data('SELECT id FROM refdesc WHERE abstract_keywords IS NOT NULL;','../../Data/dumps/20160224_cybergeo.sqlite3')
    corpus = utils.get_ids('cybergeo','keywords')
    occurence_dicos = utils.import_kw_dico('cybergeo','keywords')
    mongo = pymongo.MongoClient('localhost',27017)
    database = mongo['relevant']
    relevant = 'relevant_full_'+str(kwLimit)
    network = 'network_full_'+str(kwLimit)+'_eth'+str(eth)
    database[relevant].delete_many({"cumtermhood":{"$gt":0}})
    database[relevant].create_index('keyword')
    [keywords,dico,frequencies,edge_list] = kwFunctions.extract_relevant_keywords(corpus,kwLimit,occurence_dicos)
    print('insert relevant...')
    for kw in keywords.keys():
        butils.update_kw_tm(kw,keywords[kw],frequencies[kw],math.log(keywords[kw])*math.log(len(corpus)/frequencies[kw]),database,relevant)
    print('insert edges...')
    database[network].delete_many({"weight":{"$gt":0}})
    database[network].insert_many(edge_list)
