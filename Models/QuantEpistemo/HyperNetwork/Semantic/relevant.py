# -*- coding: utf-8 -*-

# bootstrap for relevant terms extraction

import numpy,os,pymongo,math
import kwFunctions,utils,butils



def relevant_full_corpus(mongo_base,kwLimit,eth):
    #corpus = utils.get_data('SELECT id FROM refdesc WHERE abstract_keywords IS NOT NULL;','../../Data/dumps/20160224_cybergeo.sqlite3')
    corpus = utils.get_ids(mongo_base,'keywords')
    occurence_dicos = utils.import_kw_dico(mongo_base,'keywords')
    mongo = pymongo.MongoClient('localhost',27017)
    #database = mongo['relevant']
    database = mongo[mongo_base]
    relevant = 'relevant_'+str(kwLimit)
    network = 'network_'+str(kwLimit)+'_eth'+str(eth)
    #database[relevant].delete_many({"cumtermhood":{"$gt":0}})
    database[relevant].drop()
    database[relevant].create_index('keyword')
    [keywords,dico,frequencies,edge_list] = kwFunctions.extract_relevant_keywords(corpus,kwLimit,eth,occurence_dicos)
    print('insert relevant...')
    for kw in keywords.keys():
        #print(kw+' ; '+str(keywords[kw])+' ; '+str(len(corpus)/frequencies[kw]))
        lf=0
        try:
            lf= math.log(keywords[kw])*math.log(len(corpus)/frequencies[kw])
        except Exception as e:
            print('ERROR : '+kw+' ; '+str(keywords[kw])+' ; '+str(len(corpus))+' ; '+str(frequencies[kw]))
        butils.update_kw_tm(kw,keywords[kw],frequencies[kw],lf,database,relevant)
    print('insert edges...')
    #database[network].delete_many({"weight":{"$gt":0}})
    database[network].drop()
    database[network].insert_many(edge_list)
